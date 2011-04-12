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
  int itemsPregunta [N_PAGINAS_MAX][N_ITEMS_MAX];
  CvPoint origen [N_PAGINAS_MAX];
  CvPoint destino [N_PAGINAS_MAX];  
};

struct ResultadoPagina 	
{ 
  CvPoint * puntos;
  int     * marcado;  
};


int estaMarcada(CvMat * marcadog ,  CvRect punto){
  CvScalar media;
  CvMat data;
  double media2;
  cvGetSubRect(marcadog,&data, punto);
  
  media = cvAvg(&data);
  
  IplImage stub, *dst_img;
  dst_img = cvGetImage(&data, &stub);
 // cvNamedWindow( "Demo", CV_WINDOW_NORMAL );
 // cvShowImage( "Demo",  dst_img  );
 // printf (" Valor medio: %f \n",media.val[0]);
//  cvWaitKey(0);
  
  if (media.val[0] < 200.0) return 1;
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
  double quality_level = 0.3;
  double min_distance = (marca->width);
  int eig_block_size = 12;
  int use_harris = false;
 
  cvGoodFeaturesToTrack(resultado,eig_image,temp_image,corners,&corner_count,quality_level,min_distance,NULL,eig_block_size,use_harris);

  for( int i = 0; i < corner_count; i++) {
      valores [i] = cvPoint( corners[i].x,corners[i].y);
  }
  
  *npuntos =  corner_count;
  
  cvReleaseMat(& eig_image);
  cvReleaseMat(& temp_image);
  cvReleaseImage(&resultado);
  
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

void leePaginaExamen(char * nombreExamen,CvPoint origen,CvPoint destino, int pagina,int examen,  int n_items , ResultadoPagina rp){
   // printf("leePaginaExamen %s \n",nombreExamen);
    CvMat* marcado  = cvLoadImageM(nombreExamen, CV_LOAD_IMAGE_GRAYSCALE);
    IplImage* marcadoi  = cvLoadImage(nombreExamen, CV_LOAD_IMAGE_COLOR);
    CvMat* marcadog = cvLoadImageM(nombreExamen, CV_LOAD_IMAGE_GRAYSCALE);
    CvMat* itemP    = cvLoadImageM("itemP.jpg", CV_LOAD_IMAGE_GRAYSCALE);
    CvMat* itemH    = cvLoadImageM("itemH.jpg", CV_LOAD_IMAGE_GRAYSCALE);
    

    //Corregir giro    
    int npuntos;
    CvPoint  pos [100] = {0}; 
    
   // printf("Localizando items Horizontales... \n");
    puntosParaTemplate (marcado, itemH, &npuntos, pos);
   // printf("  -> obtenidos : %d \n", npuntos);
    
    int pg= 0;
    for (int i=0; i < npuntos; i++) {
         if (  130 < pos[i].x and 
            1600 > pos[i].x and
            2200 > pos[i].y and
            2000 < pos[i].y) {
          
          pos[pg].x = pos[i].x;
          pos[pg].y = pos[i].y;
          pg ++;
          if (pg == 2) {
            npuntos=2;
            break;
          }
          

        }
    }
    
    
    
    float ang_rad = 0;
    float degrees = 0;  
    if (npuntos == 2) {
 //     printf("    -> P1 (%d,%d) \n", pos[0].x,pos[0].y);
 //     printf("    -> P2 (%d,%d) \n", pos[1].x,pos[1].y);
            
      qsort(  pos, 2, sizeof(CvPoint ), horizontal_cmp);
      
  //    printf ("    Ordenando...\n");
  //    printf("    -> P1 (%d,%d) \n", pos[0].x,pos[0].y);
  //    printf("    -> P2 (%d,%d) \n", pos[1].x,pos[1].y);      
      
      ang_rad = atan((pos[1].y-pos[0].y )/(pos[1].x-pos[0].x));
      degrees = - (180 * ang_rad / 3.14);
    } else {
      printf("Numero de puntos para giro incorrecto.\n");      
    }

    CvMat * rot_mat = cvCreateMat(2, 3, CV_32F);
    CvPoint2D32f center = cvPoint2D32f( marcado->width/2, marcado->height/2 );
    cv2DRotationMatrix( center, degrees, 1, rot_mat );
    cvWarpAffine( marcado, marcadog, rot_mat );
    cvReleaseMat(&rot_mat);
    

    
    // Posicion respuestas y marcas horizontales despues de girar
    //int npuntosHor;
    //CvPoint posHor [100] = {0};

    int npuntosRes;
    CvPoint posRes [100] = {0};

  //  puntosParaTemplate (marcadog, itemH, &npuntosHor, posHor);
  //  printf("Localizando items Horizontales despues de girar... \n");
  //  printf("  -> obtenidos : %d \n", npuntosHor);
  //  printf("    -> P1 (%d,%d) \n", posHor[0].x,posHor[0].y);
  //  printf("    -> P2 (%d,%d) \n", posHor[1].x,posHor[1].y);
   
    puntosParaTemplate (marcadog, itemP, &npuntosRes, posRes);  
    qsort(  posRes, npuntosRes, sizeof(CvPoint ), vertical_cmp);



    int nrespuesta = 0;
    for (int i=0; i < npuntosRes; i++) {
 //     CvRect rect =    cvRect( posRes[i].x+3, posRes[i].y+2, 27, 27 );
      CvRect rect =    cvRect( posRes[i].x+4, posRes[i].y+8, 12, 15 );
    //  printf (" Validando punto para pag %d (%d,%d) (%d,%d) (%d,%d)\n",pagina,origen.x,origen.y, posRes[i].x,posRes[i].y,destino.x,destino.y);
      if (  origen.x < posRes[i].x and 
            destino.x > posRes[i].x and
            origen.y > posRes[i].y and
            destino.y < posRes[i].y) {
 
          rp.puntos[nrespuesta].x = posRes[i].x;
          rp.puntos[nrespuesta].y = posRes[i].y;
          if  (estaMarcada( marcadog , rect )) rp.marcado[nrespuesta] = 1;
          nrespuesta ++ ;                  
          if (n_items < nrespuesta) {
            printf("Error al reconocer las marcas en Examen %d pagina %d \n", examen,pagina);
            break;
          }

        }
    }
    
      printf (" Puntos pag %d %d\n",pagina,nrespuesta);
      
        

    char ficheroSalida[50];
    sprintf( ficheroSalida, "./ExamenesResueltos/Ex-%d-p-%d.jpg\0", examen,pagina);
    cvSaveImage(ficheroSalida ,marcadoi);
    
   

    cvReleaseMat(&marcado);
    cvReleaseImage(&marcadoi);
    cvReleaseMat(&marcadog);
    cvReleaseMat(&itemP);
    cvReleaseMat(&itemH);
    
}


void corrijeExamen (Examen ex, int examen, ResultadoPagina * rp){
    float nota=0;
    float notap=0;
    int respuesta_contestada=-1;
    int n_paginas = ex.n_paginas;
    int num_pregunta;
    int num_pregunta_ant=0;
    
     
    for (int p = 0 ; p < n_paginas; p++) {      
      for (int i=0; i < ex.n_items[p] ;i++) {
            
        //Controlamos que una pregunta se haya contestado solo una vez para sumar
        //la nota parcial
        num_pregunta = ex.itemsPregunta[p][i];        
        if (num_pregunta_ant != num_pregunta) {
          nota += notap;
          notap=0;
        }
        num_pregunta_ant = num_pregunta;
        
        //Si esta marcado un item
        if (rp[p].marcado[i] == 1) {
          // Y ya habia una respuesta para esta pregunta....
          if (respuesta_contestada == ex.itemsPregunta[p][i]) {
            printf ("Incidente en examen %d pagina %d respuesta %d \n ",examen,p,respuesta_contestada);
            notap=0;
          }
          else {
            respuesta_contestada = num_pregunta;
            if (ex.respuestas[p][i] == 1 ) notap = 1;
            //else notap -=0.25;
          }
        }
      }
      respuesta_contestada=-1;
    }
    
    nota += notap;
    
    printf (" La nota del examen es: %f \n ",nota);
    
    CvFont font;
    cvInitFont(&font, CV_FONT_HERSHEY_SCRIPT_SIMPLEX, 4.0, 4.0, 0, 1, CV_AA);
    
    char nres[20];
       
    char ficheroEntrada[50];
    for (int p = 0 ; p< n_paginas; p++) {      
      sprintf( ficheroEntrada, "./ExamenesResueltos/Ex-%d-p-%d.jpg\0", examen,p);
      IplImage* marcadoi  = cvLoadImage(ficheroEntrada, CV_LOAD_IMAGE_COLOR);
      
      if (p==0) {
        sprintf( nres, "%2.2f\0", nota );
        cvPutText(marcadoi, nres, cvPoint(1100, 170), &font, cvScalar(0, 0, 0, 0));
      }
      
      for (int i=0; i < ex.n_items[p];i++) {
        // Punto reconocido
        cvCircle(marcadoi, cvPoint( 10, rp[p].puntos[i].y+15) , 8, CV_RGB(255,0,255), 3);
        
        if (rp[p].marcado[i] == 1) {
          cvCircle(marcadoi, cvPoint( 10, rp[p].puntos[i].y+15) , 8, CV_RGB(255,100,0), -1);
          if (ex.respuestas[p][i] == 1){ 
            cvDrawRect(marcadoi,cvPoint( rp[p].puntos[i].x+3, rp[p].puntos[i].y+2) , cvPoint(rp[p].puntos[i].x+3+40, rp[p].puntos[i].y+2+40) ,CV_RGB(0,255,0), 2);
            cvLine(marcadoi, cvPoint( rp[p].puntos[i].x-70, rp[p].puntos[i].y+2)  , cvPoint( rp[p].puntos[i].x-40, rp[p].puntos[i].y+30) , CV_RGB(0,255,0), 6);
            cvLine(marcadoi, cvPoint( rp[p].puntos[i].x-40, rp[p].puntos[i].y+30)  , cvPoint( rp[p].puntos[i].x-12, rp[p].puntos[i].y-15) , CV_RGB(0,255,0), 6);
             
          }
          else {
            cvDrawRect(marcadoi,cvPoint( rp[p].puntos[i].x+3, rp[p].puntos[i].y+2) , cvPoint(rp[p].puntos[i].x+3+40, rp[p].puntos[i].y+2+40) ,CV_RGB(255,0,0), 2);
            cvLine(marcadoi, cvPoint( rp[p].puntos[i].x-70, rp[p].puntos[i].y+2)  , cvPoint( rp[p].puntos[i].x-15, rp[p].puntos[i].y+75) , CV_RGB(255,0,0), 6);
            cvLine(marcadoi, cvPoint( rp[p].puntos[i].x-70, rp[p].puntos[i].y+75 )  , cvPoint( rp[p].puntos[i].x-15, rp[p].puntos[i].y+2)  , CV_RGB(255,0,0), 6);
             
          }
        }
        else if (ex.respuestas[p][i] == 1) 
           cvDrawRect(marcadoi,cvPoint( rp[p].puntos[i].x+3, rp[p].puntos[i].y+2) , cvPoint(rp[p].puntos[i].x+3+40, rp[p].puntos[i].y+2+40) ,CV_RGB(0,0,255), 2);
      }
      cvSaveImage(ficheroEntrada ,marcadoi);
      cvReleaseImage(&marcadoi);
    }
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
  ex.destino[0] = cvPoint(285,450);    
  
  ex.origen[1] = cvPoint(190,2100);  
  ex.destino[1] = cvPoint(285,240);    
  
  ex.origen[2] = cvPoint(190,1700);  
  ex.destino[2] = cvPoint(285,284);    
  
  ex.origen[3] = cvPoint(190,900);  
  ex.destino[3] = cvPoint(285,354);      

  ex.origen[4] = cvPoint(190,1458);  
  ex.destino[4] = cvPoint(285,1227 );      
  
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
  ex.respuestas[2][16] = 1;
 
  
  ex.respuestas[3][3] = 1;
  ex.respuestas[3][6] = 1;

  ex.respuestas[4][0] = 1;

  for (int p=0; p < 5 ; p++)
    for (int i=0; i < ex.n_items [p];i++) 
      ex.itemsPregunta[p][i] = (i/4)+1;

  
  
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
    
    
    struct ResultadoPagina * rp;
    
    
    rp = (ResultadoPagina *) malloc( ex.n_paginas * sizeof(ResultadoPagina) );
    for (int j = 0; j< ex.n_paginas; j++) {
      rp[j].puntos  = (CvPoint *) malloc(ex.n_items [j] * sizeof(CvPoint));
      rp[j].marcado = (int *) calloc(ex.n_items [j] , sizeof(int)); 
    }
                
    for (int j = 0; j< i  ; j++) {         
        printf("Leyendo imagen: %s \n",files[j]);
        sprintf(file,"./ExamenesOriginal/%s\0",files[j]);     
        leePaginaExamen(file,ex.origen[j%ex.n_paginas], ex.destino[j%ex.n_paginas] ,j%ex.n_paginas, j/ex.n_paginas,ex.n_items[j%ex.n_paginas] ,rp[j%ex.n_paginas]);        
        
        //Termino de extraer puntos de un examen entero
        if ( (j+1) % ex.n_paginas == 0)  {
          corrijeExamen(ex, j/ex.n_paginas,rp);
          for (int j = 0; j< ex.n_paginas; j++) {
            free(rp[j].marcado );
            rp[j].marcado = (int *) calloc(ex.n_items [j] , sizeof(int)); 
          }
        }
    }
   
   
   

    
    if (closedir(dip) == -1) { 
      perror("closedir"); 
      return 0; 
    } 

    
            

    return 0;
}

