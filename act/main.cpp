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


#include <stdlib.h> 
#include <sys/types.h> 
#include <dirent.h> 
#include <errno.h> 

#define N_PAGINAS_MAX 100
#define N_ITEMS_MAX 100

struct Examen 	
{ 
  int n_paginas;
  int n_items [N_PAGINAS_MAX];
  int respuestas [N_PAGINAS_MAX][N_ITEMS_MAX];
  CvPoint origen [N_PAGINAS_MAX];
  CvPoint destino [N_PAGINAS_MAX];  
};



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
 // printf ("Marca %f \n",media.val[0]);
  if (media.val[0] < 160) return 1;
  else return 0;
}

void puntosParaTemplate (CvMat * imagen, CvMat *  marca, int *npuntos, CvPoint * valores){
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

  for( int i = 0; i < corner_count; i++) {
      valores [i] = cvPoint( corners[i].x,corners[i].y);
  }
  
  *npuntos =  corner_count;
}


int horizontal_cmp(const void *a, const void *b)  {
  const CvPoint *p1 = (const CvPoint *)a;
  const CvPoint *p2 = (const CvPoint *)b;
  if (p1->x < p2->x) return -1;
  else if (p1->x == p2->x) return 0;
  else return 1;
}


int vertical_cmp(const void *a, const void *b)  {
  const CvPoint *p1 = (const CvPoint *)a;
  const CvPoint *p2 = (const CvPoint *)b;
  if (p1->y < p2->y) return -1;
  else if (p1->y == p2->y) return 0;
  else return 1;
}

void leeExamen(char * nombreExamen,Examen ex, int pagina,int examen){
    printf("leeExamen %s \n",nombreExamen);
    CvMat* marcado  = cvLoadImageM(nombreExamen, CV_LOAD_IMAGE_GRAYSCALE);
    IplImage* marcadoi  = cvLoadImage(nombreExamen, CV_LOAD_IMAGE_COLOR);
    CvMat* marcadog = cvLoadImageM(nombreExamen, CV_LOAD_IMAGE_GRAYSCALE);
    CvMat* itemP    = cvLoadImageM("itemP.jpg", CV_LOAD_IMAGE_GRAYSCALE);
    CvMat* itemH    = cvLoadImageM("itemH.jpg", CV_LOAD_IMAGE_GRAYSCALE);
    

    //Corregir giro    
    int npuntos;
    CvPoint  pos [100] = {0}; 
    
    printf("Localizando items Horizontales... \n");
    puntosParaTemplate (marcado, itemH, &npuntos, pos);
    printf("  -> obtenidos : %d \n", npuntos);
          
    if (npuntos == 2) {
      printf("    -> P1 (%d,%d) \n", pos[0].x,pos[0].y);
      printf("    -> P2 (%d,%d) \n", pos[1].x,pos[1].y);
            
      qsort(  pos, 2, sizeof(CvPoint ), horizontal_cmp);
      
      printf ("    Ordenando...\n");
      printf("    -> P1 (%d,%d) \n", pos[0].x,pos[0].y);
      printf("    -> P2 (%d,%d) \n", pos[1].x,pos[1].y);      
            
      CvMat * rot_mat = cvCreateMat(2, 3, CV_32F);
      float ang_rad = atan((pos[1].y-pos[0].y )/(pos[1].x-pos[0].x));
      float degrees = - (180 * ang_rad / 3.14);
      CvPoint2D32f center = cvPoint2D32f( marcado->width/2, marcado->height/2 );
      cv2DRotationMatrix( center, degrees, 1, rot_mat );
      cvWarpAffine( marcado, marcadog, rot_mat );
    } else printf("Numero de punto de giro incorrecto.\n");
    
    
    
    // Posicion respuestas y marcas horizontales despues de girar
    int npuntosHor;
    CvPoint posHor [100] = {0};

    int npuntosRes;
    CvPoint posRes [100] = {0};

    puntosParaTemplate (marcadog, itemH, &npuntosHor, posHor);
    printf("Localizando items Horizontales despues de girar... \n");
    printf("  -> obtenidos : %d \n", npuntosHor);
    printf("    -> P1 (%d,%d) \n", posHor[0].x,posHor[0].y);
    printf("    -> P2 (%d,%d) \n", posHor[1].x,posHor[1].y);
   
    puntosParaTemplate (marcadog, itemP, &npuntosRes, posRes);  
    qsort(  posRes, npuntosRes, sizeof(CvPoint ), vertical_cmp);

    CvPoint origen =  ex.origen[pagina];
    CvPoint destino =  ex.destino[pagina];
    int nrespuesta = 0;
    for (int i=0; i < npuntosRes; i++) {
      CvRect rect =    cvRect( posRes[i].x+3, posRes[i].y+2, 27, 27 );

      printf (" Validando punto para pag %d (%d,%d) (%d,%d) (%d,%d)\n",pagina,origen.x,origen.y, posRes[i].x,posRes[i].y,destino.x,destino.y);
      if (  origen.x < posRes[i].x and 
            destino.x > posRes[i].x and
            origen.y > posRes[i].y and
            destino.y < posRes[i].y) {
            
         //      cvDrawRect(marcadoi,cvPoint(posRes[i].x+3, posRes[i].y+2) , cvPoint(posRes[i].x+3+40, posRes[i].y+2+40) ,CV_RGB(0,255,0), 2);
        if ( (  (posRes[i].y+2)   > 192) and   ( (posRes[i].y+2)  < 2000)  ) {
          if  (estaMarcada( marcadog , rect )) {
            if (ex.respuestas[pagina][nrespuesta]) {
               cvDrawRect(marcadoi,cvPoint(posRes[i].x+3, posRes[i].y+2) , cvPoint(posRes[i].x+3+20, posRes[i].y+2+20) ,CV_RGB(255,0,0), 2);
            }
            else {         
               cvDrawRect(marcadoi,cvPoint(posRes[i].x+3, posRes[i].y+2) , cvPoint(posRes[i].x+3+20, posRes[i].y+2+20) ,CV_RGB(0,255,0), 2);
            }
          } else if (    cvDrawRect(marcadoi,cvPoint(posRes[i].x+3, posRes[i].y+2) , cvPoint(posRes[i].x+3+20, posRes[i].y+2+20) ,CV_RGB(255,0,0), 2);){
          
          }
        }
        nrespuesta ++ ;
      }
    }
    
    CvMat data[8];
   
    float puntoVal = posHor[1].x-57;
    CvRect punto =  cvRect( posHor[1].x-57, posHor[1].y+4, 30, 32 );

    for (int i=0; i < 8; i++) {  
      cvGetSubRect(marcadog,&data[i], punto);
      puntoVal -= 55;
      punto =  cvRect( puntoVal, posHor[1].y+4, 30, 32 );
      
    }
    
    cvNamedWindow( "Demo", CV_WINDOW_NORMAL );
    cvShowImage( "Demo", marcadoi  );
//    cvWaitKey(0);
    
    char ficheroSalida[50];
    sprintf( ficheroSalida, "./ExamenesResueltos/Ex-%d-p-%d.jpg\0", examen,pagina);
    cvSaveImage(ficheroSalida ,marcadoi);
    
/*    //OCR
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
*/



    cvRelease(marcado);
    cvRelease(marcadoi);
    cvRelease(marcadog);
    cvRelease(itemP);
    cvRelease(itemH);
    
}

int cstring_cmp(const void *a, const void *b) 
{ 
    const char **ia = (const char **)a;
    const char **ib = (const char **)b;
    return strcmp(*ia, *ib);
	/* strcmp functions works exactly as expected from
	comparison function */ 
} 
 
 
int main( int argc, char** argv )
{
  int tam;
  char * cadena;
  char * files [1000];
  char file[255];
	       
  DIR *dip; 
  struct dirent   *dit; 
  int             i = 0; 

  struct Examen ex;
  ex.n_paginas = 5;
  ex.n_items [0]  = 24;
  ex.n_items [1]  = 24;
  ex.n_items [2]  = 20;
  ex.n_items [3]  = 8;
  ex.n_items [4]  = 4;  
  
  
  
  // desde punto inferior izquierda hasta punto superior derecho
  ex.origen[0] = cvPoint(190,2000);  
  ex.destino[0] = cvPoint(267,450);    
  
  ex.origen[1] = cvPoint(190,2000);  
  ex.destino[1] = cvPoint(267,264);    
  
  ex.origen[2] = cvPoint(190,1700);  
  ex.destino[2] = cvPoint(267,284);    
  
  ex.origen[3] = cvPoint(190,900);  
  ex.destino[3] = cvPoint(267,354);      

  ex.origen[4] = cvPoint(190,1458);  
  ex.destino[4] = cvPoint(267,1227 );      
  
  ex.respuestas[0][0]  = 1;
  ex.respuestas[0][5]  = 1;
  ex.respuestas[0][11] = 1;
  ex.respuestas[0][15] = 1;  
  ex.respuestas[0][16] = 1;  
  ex.respuestas[0][22] = 1;  
    
  ex.respuestas[1][1] = 1;
  ex.respuestas[1][5] = 1;
  ex.respuestas[1][10] = 1;
  ex.respuestas[1][15] = 1;
  ex.respuestas[1][16] = 1;
  ex.respuestas[1][23] = 1;
  
  
  ex.respuestas[2][3] = 1;
  ex.respuestas[2][7] = 1;
  ex.respuestas[2][11] = 1;
  ex.respuestas[2][12] = 1;
  
 
  
  ex.respuestas[3][3] = 1;
  ex.respuestas[3][7] = 1;

  ex.respuestas[4][0] = 1;


  


  printf ("OCR\n");
  basicOCR();
    
  if ((dip = opendir("./ExamenesOriginal/")) == NULL) { 
    perror("opendir"); 
    return 0; 
  } 
    
    
    while ((dit = readdir(dip)) != NULL){ 
      tam = strlen(dit->d_name);
      cadena = &(dit->d_name[tam-4]);
      if (not strcmp(cadena, ".jpg\0")) {
        files [i] = dit->d_name;
        i++;         
      }
    } 
 
    qsort(files, i, sizeof(char *), cstring_cmp);
    int contador_examenes;
    for (int j = 0; j< i ; j++) {
        printf("Reconocimiento de examenes %s \n",files[j]);
        sprintf(file,"./ExamenesOriginal/%s\0",files[j]);        
        leeExamen(file,ex,j%ex.n_paginas, j/ex.n_paginas);        
    }
   

    
    if (closedir(dip) == -1) { 
      perror("closedir"); 
      return 0; 
    } 

    
            

    return 0;
}

