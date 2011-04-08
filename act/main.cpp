#ifdef _CH_
#pragma package <opencv>
#endif

#ifndef _EiC
#include <cv.h>
#include <highgui.h>
#include <stdio.h>
#include <ctype.h>
#endif
#include <math.h>

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

    puntosParaTemplate (marcado, itemH, &npuntosHor, posHor);
   
    puntosParaTemplate (marcadog, itemP, &npuntosRes, posRes);  

    for (int i=0; i < npuntosRes; i++) {
      CvRect rect =    cvRect( posRes[(i*2)]+3, posRes[(i*2)+1]+2, 27, 27 );
      cvDrawRect(marcadoi,cvPoint(posRes[(i*2)]+3, posRes[(i*2)+1]+2) , cvPoint(posRes[(i*2)]+3+40, posRes[(i*2)+1]+2+40) ,CV_RGB(0,255,0), 2);
      if  (estaMarcada( marcadog , rect )){
        cvDrawRect(marcadoi,cvPoint(posRes[(i*2)]+3, posRes[(i*2)+1]+2) , cvPoint(posRes[(i*2)]+3+20, posRes[(i*2)+1]+2+20) ,CV_RGB(255,0,0), 2);
        printf ("  Respuesta marcada: %d \n  " , i);
      }
    }
    
    IplImage* screenBuffer;
    screenBuffer=cvCloneImage(marcadoi);
    cvNamedWindow( "Demo", CV_WINDOW_AUTOSIZE );
    cvShowImage( "Demo", marcadoi  );
    cvWaitKey(0);

}


int main( int argc, char** argv )
{
    printf( "Reconocimiento de examenes\n");
    leeExamen("./ex-001.jpg");
    return 0;
}

