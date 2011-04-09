#ifdef _CH_
#pragma package <opencv>
#endif

#ifndef _EiC
#include <cv.h>
#include <highgui.h>
#include <stdio.h>
#include <ctype.h>
#include "ml.h"
#endif
#include <math.h>
/****OCR****/
void findX(IplImage* imgSrc,int* min, int* max){
	int i;
	int minFound=0;
	CvMat data;
	CvScalar maxVal=cvRealScalar(imgSrc->width * 255);
	CvScalar val=cvRealScalar(0);
	//For each col sum, if sum < width*255 then we find the min 
	//then continue to end to search the max, if sum< width*255 then is new max
	for (i=0; i< imgSrc->width; i++){
		cvGetCol(imgSrc, &data, i);
		val= cvSum(&data);
		if(val.val[0] < maxVal.val[0]){
			*max= i;
			if(!minFound){
				*min= i;
				minFound= 1;
			}
		}
	}
}

void findY(IplImage* imgSrc,int* min, int* max){
	int i;
	int minFound=0;
	CvMat data;
	CvScalar maxVal=cvRealScalar(imgSrc->width * 255);
	CvScalar val=cvRealScalar(0);
	//For each col sum, if sum < width*255 then we find the min 
	//then continue to end to search the max, if sum< width*255 then is new max
	for (i=0; i< imgSrc->height; i++){
		cvGetRow(imgSrc, &data, i);
		val= cvSum(&data);
		if(val.val[0] < maxVal.val[0]){
			*max=i;
			if(!minFound){
				*min= i;
				minFound= 1;
			}
		}
	}
}
CvRect findBB(IplImage* imgSrc){
	CvRect aux;
	int xmin, xmax, ymin, ymax;
	xmin=xmax=ymin=ymax=0;

	findX(imgSrc, &xmin, &xmax);
	findY(imgSrc, &ymin, &ymax);
	
	aux=cvRect(xmin, ymin, xmax-xmin, ymax-ymin);
	
	return aux;
	
}

IplImage preprocessing(IplImage* imgSrc,int new_width, int new_height){
	IplImage* result;
	IplImage* scaledResult;

	CvMat data;
	CvMat dataA;
	CvRect bb;//bounding box
	CvRect bba;//boundinb box maintain aspect ratio
	
	//Find bounding box
	bb=findBB(imgSrc);
	
	//Get bounding box data and no with aspect ratio, the x and y can be corrupted
	cvGetSubRect(imgSrc, &data, cvRect(bb.x, bb.y, bb.width, bb.height));
	//Create image with this data with width and height with aspect ratio 1 
	//then we get highest size betwen width and height of our bounding box
	int size=(bb.width>bb.height)?bb.width:bb.height;
	result=cvCreateImage( cvSize( size, size ), 8, 1 );
	cvSet(result,CV_RGB(255,255,255),NULL);
	//Copy de data in center of image
	int x=(int)floor((float)(size-bb.width)/2.0f);
	int y=(int)floor((float)(size-bb.height)/2.0f);
	cvGetSubRect(result, &dataA, cvRect(x,y,bb.width, bb.height));
	cvCopy(&data, &dataA, NULL);
	//Scale result
	scaledResult=cvCreateImage( cvSize( new_width, new_height ), 8, 1 );
	cvResize(result, scaledResult, CV_INTER_NN);
	
	//Return processed data
	return *scaledResult;
	
}

char file_path[] = "../OCRf/";

int train_samples = 50;
int classes= 10;
CvMat* trainData;
CvMat* trainClasses;

int size=40;

const int K=10;
CvKNearest *knn;


void getData()
{
	IplImage* src_image;
	IplImage prs_image;
	CvMat row,data;
	char file[255];
	int i,j;
	for(i =0; i<classes; i++){
		for( j = 0; j< train_samples; j++){
			
			//Load file
			if(j<10)
				sprintf(file,"%s%d/%d0%d.pbm",file_path, i, i , j);
			else
				sprintf(file,"%s%d/%d%d.pbm",file_path, i, i , j);
			src_image = cvLoadImage(file,0);
			if(!src_image){
				printf("Error: Cant load image %s\n", file);
				//exit(-1);
			}
			//process file
			prs_image = preprocessing(src_image, size, size);
			
			//Set class label
			cvGetRow(trainClasses, &row, i*train_samples + j);
			cvSet(&row, cvRealScalar(i));
			//Set data 
			cvGetRow(trainData, &row, i*train_samples + j);

			IplImage* img = cvCreateImage( cvSize( size, size ), IPL_DEPTH_32F, 1 );
			//convert 8 bits image to 32 float image
			cvConvertScale(&prs_image, img, 0.0039215, 0);

			cvGetSubRect(img, &data, cvRect(0,0, size,size));
			
			CvMat row_header, *row1;
			//convert data matrix sizexsize to vecor
			row1 = cvReshape( &data, &row_header, 0, 1 );
			cvCopy(row1, &row, NULL);
		}
	}
}

void train()
{
	knn=new CvKNearest( trainData, trainClasses, 0, false, K );
}

float classify(IplImage* img, int showResult)
{
	IplImage prs_image;
	CvMat data;
	CvMat* nearest=cvCreateMat(1,K,CV_32FC1);
	float result;
	//process file
	prs_image = preprocessing(img, size, size);
	
	//Set data 
	IplImage* img32 = cvCreateImage( cvSize( size, size ), IPL_DEPTH_32F, 1 );
	cvConvertScale(&prs_image, img32, 0.0039215, 0);
	cvGetSubRect(img32, &data, cvRect(0,0, size,size));
	CvMat row_header, *row1;
	row1 = cvReshape( &data, &row_header, 0, 1 );

	result=knn->find_nearest(row1,K,0,0,nearest,0);
	
	int accuracy=0;
	for(int i=0;i<K;i++){
		if( nearest->data.fl[i] == result)
                    accuracy++;
	}
	float pre=100*((float)accuracy/(float)K);
	if(showResult==1){
		printf("|\t%.0f\t| \t%.2f%%  \t| \t%d of %d \t| \n",result,pre,accuracy,K);
		printf(" ---------------------------------------------------------------\n");
	}

	return result;

}

void test(){
	IplImage* src_image;
	IplImage prs_image;
	CvMat row,data;
	char file[255];
	int i,j;
	int error=0;
	int testCount=0;
	for(i =0; i<classes; i++){
		for( j = 50; j< 50+train_samples; j++){
			
			sprintf(file,"%s%d/%d%d.pbm",file_path, i, i , j);
			src_image = cvLoadImage(file,0);
			if(!src_image){
				printf("Error: Cant load image %s\n", file);
				//exit(-1);
			}
			//process file
			prs_image = preprocessing(src_image, size, size);
			float r=classify(&prs_image,0);
			if((int)r!=i)
				error++;
			
			testCount++;
		}
	}
	float totalerror=100*(float)error/(float)testCount;
	printf("System Error: %.2f%%\n", totalerror);
	
}

void basicOCR()
{

	//initial
	sprintf(file_path , "../OCR/");
	train_samples = 50;
	classes= 10;
	size=40;

	trainData = cvCreateMat(train_samples*classes, size*size, CV_32FC1);
	trainClasses = cvCreateMat(train_samples*classes, 1, CV_32FC1);

	//Get data (get images and process it)
	getData();
	
	//train	
	train();
	//Test	
	test();
	
	printf(" ---------------------------------------------------------------\n");
	printf("|\tClass\t|\tPrecision\t|\tAccuracy\t|\n");
	printf(" ---------------------------------------------------------------\n");

	
}

/**end OCR**/
int estaMarcada(CvMat * marcadog ,  CvRect punto){
  CvScalar media;
  CvMat data;
  double media2;
  cvGetSubRect(marcadog,&data, punto);
  media = cvAvg(&data);
  if (media.val[0] < 250) return 1;
  else return 0;
}

void puntosParaTemplate (CvMat * imagen, CvMat *  marca, int *npuntos, float * valores){
  const int MAX_CORNERS = 100;
  CvPoint2D32f corners[MAX_CORNERS] = {0};

  int res_width  = imagen->width  - marca->width  + 1;
  int res_height = imagen->height - marca->height + 1;
  IplImage * resultado  = cvCreateImage( cvSize( res_width, res_height ), IPL_DEPTH_32F, 1 );
  cvMatchTemplate(imagen,marca,resultado, CV_TM_SQDIFF);

  CvMat * eig_image  = cvCreateMat(imagen->rows, imagen->cols, CV_32FC1);
  CvMat * temp_image = cvCreateMat(imagen->rows, imagen->cols, CV_32FC1);
  int corner_count = MAX_CORNERS;
  double quality_level = 0.2;
  double min_distance = marca->width;
  int eig_block_size = 3;
  int use_harris = false;
 
  cvGoodFeaturesToTrack(resultado,eig_image,temp_image,corners,&corner_count,quality_level,min_distance,NULL,eig_block_size,use_harris);

  //TODO: Ordenar puntos
  for( int i = 0; i < corner_count; i++) {
      valores [(i*2)] = corners[i].x;
      valores [(i*2)+1] = corners[i].y;
      printf ("Punto: %f %f  \n ", corners[i].x, corners[i].y);
  }
  *npuntos =  corner_count;
}


void leeExamen(char * nombreExamen){
    printf("leeExamen %s \n",nombreExamen);
    CvMat* marcado  = cvLoadImageM(nombreExamen, CV_LOAD_IMAGE_GRAYSCALE);
    IplImage* marcadoi  = cvLoadImage(nombreExamen, CV_LOAD_IMAGE_COLOR);
    CvMat* marcadog = cvLoadImageM(nombreExamen, CV_LOAD_IMAGE_GRAYSCALE);
    CvMat* itemP    = cvLoadImageM("itemP.jpg", CV_LOAD_IMAGE_GRAYSCALE);
    CvMat* itemH    = cvLoadImageM("itemH.jpg", CV_LOAD_IMAGE_GRAYSCALE);
    //Corregir giro    
    int npuntos;
    float pos [50] = {0}; 
    puntosParaTemplate (marcado, itemH, &npuntos, pos);
    int x1 = (int) pos[0];
    int y1 = (int) pos[1];
    int x2 = (int) pos[2];
    int y2 = (int) pos[3];
    CvMat * rot_mat = cvCreateMat(2, 3, CV_32F);
    float ang_rad = atan((y2-y1)/(x2-x1));
    float degrees = - (180 * ang_rad / 3.14);
    CvPoint2D32f center = cvPoint2D32f( marcado->width/2, marcado->height/2 );
    cv2DRotationMatrix( center, degrees, 1, rot_mat );
    cvWarpAffine( marcado, marcadog, rot_mat );

    // Posicion respuestas y marcas horizontales despues de girar
    int npuntosHor;
    float posHor [50] = {0};

    int npuntosRes;
    float posRes [50] = {0};

    puntosParaTemplate (marcadog, itemH, &npuntosHor, posHor);
   
    puntosParaTemplate (marcadog, itemP, &npuntosRes, posRes);  

    for (int i=0; i < npuntosRes; i++) {
      CvRect rect =    cvRect( posRes[(i*2)]+3, posRes[(i*2)+1]+2, 27, 27 );
      cvDrawRect(marcadoi,cvPoint(posRes[(i*2)]+3, posRes[(i*2)+1]+2) , cvPoint(posRes[(i*2)]+3+40, posRes[(i*2)+1]+2+40) ,CV_RGB(0,255,0), 2);
      if  (estaMarcada( marcadog , rect )){
        cvDrawRect(marcadoi,cvPoint(posRes[(i*2)]+3, posRes[(i*2)+1]+2) , cvPoint(posRes[(i*2)]+3+20, posRes[(i*2)+1]+2+20) ,CV_RGB(255,0,0), 2);
        printf ("  Respuesta marcada: %d \n  " , i);
      }
    }
    
    CvMat data[8];
   
    float puntoVal = posHor[2]-57;
    CvRect punto =  cvRect( posHor[2]-57, posHor[3]+4, 30, 32 );

    for (int i=0; i < 8; i++) {  
      cvGetSubRect(marcadog,&data[i], punto);
      puntoVal -= 55;
      punto =  cvRect( puntoVal, posHor[3]+4, 30, 32 );
      
    }
    
    //OCR
    float num;
    char ventana[15];
    char nres[2];
    IplImage stub, *dst_img,*dst_imgp;
    
    CvFont font;
    cvInitFont(&font, CV_FONT_HERSHEY_SIMPLEX, 2.0, 2.0, 0, 1, CV_AA);
    
 
    

    for (int i=7; 0 <= i; i--) {  
      dst_img = cvGetImage(&data[i], &stub);
      num =  classify(dst_img, 1);
      printf(" Resultado OCR D %d : %f \n",i,num);
      sprintf( ventana, "Digito %d\0", i );
      sprintf( nres, "%d\0", (int)num );
      dst_imgp = cvCreateImage( cvSize(200, 200) ,  dst_img ->depth,  dst_img ->nChannels );
      cvResize(dst_img, dst_imgp);
      cvPutText(dst_imgp, nres, cvPoint(0, 35), &font, cvScalar(0, 0, 0, 0));

      cvShowImage( ventana, dst_imgp   );
    }

    
    cvNamedWindow( "Demo", CV_WINDOW_AUTOSIZE );
    cvShowImage( "Demo", marcadoi  );
    cvWaitKey(0);

}


int main( int argc, char** argv )
{

 
   

    printf ("OCR\n");
    basicOCR();
    printf( "Reconocimiento de examenes\n");
    leeExamen("./ex-002.jpg");
    return 0;
}

