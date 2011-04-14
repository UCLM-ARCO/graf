#ifdef _CH_
#pragma package <opencv>
#endif

#include <cv.h>
#include <highgui.h>
#include <stdio.h>
#include <ctype.h>
#include "ml.h"
#include <math.h>
#include <getopt.h>

#include <stdlib.h> 
#include <sys/types.h> 
#include <dirent.h> 
#include <errno.h> 


#define MAX_FILES 1000
#define MAX_LEN_FILENAME 255


void debugWindow( CvMat * c ){
  IplImage stub, *dst_img;
  dst_img = cvGetImage(c, &stub);
  cvNamedWindow( "Debug", CV_WINDOW_NORMAL );
  cvShowImage( "Debug",  dst_img  );
  cvWaitKey(0);  
}


/*******************************************************************************
 ***********Estructura de datos para información de un examen*******************
 ******************************************************************************/
#define N_PAGINAS_MAX 100
#define N_ITEMS_MAX 100
struct Examen 	
{ 
  int n_paginas;
  int n_items           [N_PAGINAS_MAX];
  int respuestas        [N_PAGINAS_MAX][N_ITEMS_MAX];
  int itemsPregunta     [N_PAGINAS_MAX][N_ITEMS_MAX];
  CvRect pos_respuestas [N_PAGINAS_MAX];
};
/******************************************************************************/


/*******************************************************************************
 ******Estructura de datos para informacion de marcas***************************
 **********************en una pagina********************************************
 ******************************************************************************/
struct ResultadoPagina 	
{
  CvPoint * puntos;
  int     * marcado;
};
/******************************************************************************/



/*******************************************************************************
 *****************************Sistema de lectura********************************
 ******************************************************************************/
 
#define MAX_CORNERS  100 //Numero maximo de marcas en una pagina

/***** Dado un rectangulo de una imagen, decide si esta marcado o no **********/
int estaMarcada(CvMat * marcadog ,  CvRect punto){
  CvScalar media;
  CvMat data;
  double media2;
  cvGetSubRect(marcadog,&data, punto);
  
  media = cvAvg(&data);
 
  if (media.val[0] < 200.0) return 1;
  else return 0;
}


/**************Dada una marca, se busca en la imagen, se************************
 ************devuelve el numero de puntos y las posiciones*********************/
void puntosParaTemplate (CvMat * imagen, CvMat *  marca, int puntos_a_encontrar,
                         int *npuntos  , CvPoint * valores){
  CvPoint2D32f corners[MAX_CORNERS] = {0};
  int res_width  = imagen->width  - marca->width  + 1;
  int res_height = imagen->height - marca->height + 1;
  
  //Reservamos memoria para matrices e imagen
  IplImage * resultado  = cvCreateImage( cvSize( res_width, res_height ) ,
                                         IPL_DEPTH_32F, 1 );
  CvMat    * eig_image  = cvCreateMat  ( imagen->rows, imagen->cols, CV_32FC1);
  CvMat    * temp_image = cvCreateMat  ( imagen->rows, imagen->cols, CV_32FC1);
  
  // Buscamos la marca en la imagen
  cvMatchTemplate(imagen,marca,resultado,CV_TM_CCORR_NORMED); //CV_TM_SQDIFF_NORMED); // CV_TM_SQDIFF);

  // De resultado localizamos los puntos donde se han encontrado las marcas  
  int corner_count     = puntos_a_encontrar; //MAX_CORNERS;
  double quality_level = 0.2;
  double min_distance  = marca->width+3;
  int eig_block_size   = 12;
  int use_harris       = false; 
  cvGoodFeaturesToTrack  ( resultado, eig_image, temp_image,
                            corners, &corner_count, quality_level, 
                            min_distance, NULL, eig_block_size, use_harris);

  //Almacenamos los resultados
  *npuntos =  corner_count;
  for( int i = 0; i < corner_count; i++) valores [i] = cvPoint( corners[i].x,corners[i].y); 
    
  //Liberamos matrices e imagen  
  cvReleaseMat  (& eig_image);
  cvReleaseMat  (& temp_image);
  cvReleaseImage(&resultado);  
}

// Ordenar puntos por la coordenada horizontal
int horizontal_cmp(const void *a, const void *b)  {
  const CvPoint *p1 = (const CvPoint *)a;
  const CvPoint *p2 = (const CvPoint *)b;
  if (p1->x < p2->x) return -1;
  else if (p1->x == p2->x) return 0;
  else return 1;
}

// Ordenar puntos por la coordenada vertical
int vertical_cmp(const void *a, const void *b)  {
  const CvPoint *p1 = (const CvPoint *)a;
  const CvPoint *p2 = (const CvPoint *)b;
  if (p1->y < p2->y) return -1;
  else if (p1->y == p2->y) return 0;
  else return 1;
}

// Gira el examen
void prepararImagen (char * nombreExamen, int examen, int pagina){

  char nombre_fichero_salida [MAX_LEN_FILENAME];

  CvMat* pagina_examen    = cvLoadImageM(nombreExamen, CV_LOAD_IMAGE_GRAYSCALE);  
  CvMat* pagina_preparada = cvLoadImageM(nombreExamen, CV_LOAD_IMAGE_GRAYSCALE);  
  CvMat* marca_horizontal = cvLoadImageM("itemH.jpg" , CV_LOAD_IMAGE_GRAYSCALE);

  CvMat*       matriz_rotacion = cvCreateMat ( 2 , 3 , CV_32F);
  CvPoint2D32f centro          = cvPoint2D32f( pagina_examen->width/2, pagina_examen->height/2 );

  int npuntos;
  CvPoint pos [5]; 

  CvRect rectangulo = cvRect(140,2100,1400,100);
  CvMat  parte_examen_inferior;
  cvGetSubRect(pagina_examen,&parte_examen_inferior, rectangulo);

  //debugWindow(&parte_examen_inferior);

  puntosParaTemplate (& parte_examen_inferior , marca_horizontal, 2 ,&npuntos, pos);
  
  float ang_rad = 0;
  float degrees = 0;  
  
  if (npuntos == 2) {
    qsort(  pos, 2, sizeof(CvPoint), horizontal_cmp);   
    ang_rad = atan(( (float)  pos[1].y-pos[0].y )/((float) pos[1].x-pos[0].x));
    degrees = (180.0 * ang_rad / 3.141592654);
  } else printf(" !! !! Numero de puntos para giro incorrecto %d %d %d.\n", examen,pagina,npuntos);      

  
  cv2DRotationMatrix( centro       , degrees         , 1, matriz_rotacion );
  cvWarpAffine      ( pagina_examen, pagina_preparada,    matriz_rotacion );

  sprintf( nombre_fichero_salida , 
           "./ExamenesPreparados/Ex-%03d-p-%03d.jpg\0", examen, pagina);
       
  cvSaveImage (nombre_fichero_salida , pagina_preparada);
  cvReleaseMat(&matriz_rotacion);
  cvReleaseMat(&marca_horizontal);
  cvReleaseMat(&pagina_examen);
  cvReleaseMat(&pagina_preparada);
  printf("prepararImagen: %s examen %d pagina %d giro %2.2f \n",nombreExamen,examen,pagina,degrees);
}

// Lee un fichero
int leePaginaExamen (char * nombreExamen, CvRect rectangulo, 
                      int n_items        , ResultadoPagina rp ){
  printf("leePaginaExamen %s \n",nombreExamen);
  CvMat* pagina_examen   = cvLoadImageM(nombreExamen, CV_LOAD_IMAGE_GRAYSCALE);
  CvMat* itemP    = cvLoadImageM("itemP.jpg", CV_LOAD_IMAGE_GRAYSCALE);
    
  int npuntosRes;
  CvPoint posRes [MAX_CORNERS] = {0};
    
  CvMat  parte_examen_preguntas;
  cvGetSubRect(pagina_examen,&parte_examen_preguntas, rectangulo);
  //debugWindow(&parte_examen_preguntas);
  
  puntosParaTemplate (&parte_examen_preguntas, itemP, n_items , &npuntosRes, posRes);  
  qsort(  posRes, npuntosRes, sizeof(CvPoint ), vertical_cmp);

  for (int i=0; i < npuntosRes; i++) {
    CvRect rect = cvRect( rectangulo.x+posRes[i].x+4, rectangulo.y+posRes[i].y+8, 12, 15 );  
    rp.puntos[i].x = rectangulo.x+posRes[i].x;
    rp.puntos[i].y = rectangulo.y+posRes[i].y;
    if (estaMarcada( pagina_examen , rect )) rp.marcado[i] = 1;
  }

  cvReleaseMat(&pagina_examen);
  cvReleaseMat(&itemP);
  
   if (n_items != npuntosRes) {
    printf("  !! Lectura !! Error marcas necesarias: %d obtenidas: %d \n",n_items,npuntosRes);
    return npuntosRes;
  }
  else{
    printf("  OK\n");
    return 0;
  }
}
/******************************************************************************/

/*******************************************************************************
 ***********************Sistema de correcion de examen**************************
 ******************************************************************************/
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
	  printf ("  !! Correcion !! Incidente en examen %d pagina %d respuesta %d \n ",examen,p,respuesta_contestada);
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
    
  printf (" OK Nota: %2.2f \n ",nota);
    
  CvFont font;
  cvInitFont(&font, CV_FONT_HERSHEY_SCRIPT_SIMPLEX, 4.0, 4.0, 0, 1, CV_AA);
    
  char nres[20];
       
  char ficheroEntrada[MAX_LEN_FILENAME];
  char ficheroSalida[MAX_LEN_FILENAME];
  
  for (int p = 0 ; p< n_paginas; p++) {      
    sprintf( ficheroEntrada, "./ExamenesPreparados/Ex-%03d-p-%03d.jpg\0", examen,p);
    sprintf( ficheroSalida ,  "./ExamenesResueltos/Ex-%03d-p-%03d.jpg\0", examen,p);    
    IplImage* pagina_examen  = cvLoadImage(ficheroEntrada, CV_LOAD_IMAGE_COLOR);
      
    if (p==0) {
      sprintf( nres, "%2.2f\0", nota );
      cvPutText(pagina_examen, nres, cvPoint(1100, 170), &font, cvScalar(0, 0, 0, 0));
    }
      
    for (int i=0; i < ex.n_items[p];i++) {
      // Punto reconocido
      cvCircle(pagina_examen, cvPoint( 10, rp[p].puntos[i].y+15) , 8, CV_RGB(255,0,255), 3);
        
      if (rp[p].marcado[i] == 1) {
	cvCircle(pagina_examen, cvPoint( 10, rp[p].puntos[i].y+15) , 8, CV_RGB(255,100,0), -1);
	if (ex.respuestas[p][i] == 1){ 
	  cvDrawRect(pagina_examen,cvPoint( rp[p].puntos[i].x+3, rp[p].puntos[i].y+2) , cvPoint(rp[p].puntos[i].x+3+40, rp[p].puntos[i].y+2+40) ,CV_RGB(0,255,0), 2);
	  cvLine(pagina_examen, cvPoint( rp[p].puntos[i].x-70, rp[p].puntos[i].y+2)  , cvPoint( rp[p].puntos[i].x-40, rp[p].puntos[i].y+30) , CV_RGB(0,255,0), 6);
	  cvLine(pagina_examen, cvPoint( rp[p].puntos[i].x-40, rp[p].puntos[i].y+30)  , cvPoint( rp[p].puntos[i].x-12, rp[p].puntos[i].y-15) , CV_RGB(0,255,0), 6);
             
	}
	else {
	  cvDrawRect(pagina_examen,cvPoint( rp[p].puntos[i].x+3, rp[p].puntos[i].y+2) , cvPoint(rp[p].puntos[i].x+3+40, rp[p].puntos[i].y+2+40) ,CV_RGB(255,0,0), 2);
	  cvLine(pagina_examen, cvPoint( rp[p].puntos[i].x-70, rp[p].puntos[i].y+2)  , cvPoint( rp[p].puntos[i].x-15, rp[p].puntos[i].y+75) , CV_RGB(255,0,0), 6);
	  cvLine(pagina_examen, cvPoint( rp[p].puntos[i].x-70, rp[p].puntos[i].y+75 )  , cvPoint( rp[p].puntos[i].x-15, rp[p].puntos[i].y+2)  , CV_RGB(255,0,0), 6);
             
	}
      }
      else if (ex.respuestas[p][i] == 1) 
	cvDrawRect(pagina_examen,cvPoint( rp[p].puntos[i].x+3, rp[p].puntos[i].y+2) , cvPoint(rp[p].puntos[i].x+3+40, rp[p].puntos[i].y+2+40) ,CV_RGB(0,0,255), 2);
    }
    cvSaveImage(ficheroSalida ,pagina_examen);
    cvReleaseImage(&pagina_examen);
  }
}
/******************************************************************************/
 

          
/*******************************************************************************
 ****************Almacenamiento de marcas en ficheros***************************
 ******************************************************************************/
void writeFile(FILE * f, Examen ex , ResultadoPagina * rp){
  fwrite(&ex.n_paginas, sizeof(int), 1, f);
  for (int p=0 ; p < ex.n_paginas ; p++) {
    fwrite(&ex.n_items[p], sizeof(int), 1, f);
    for (int i=0; i < ex.n_items[p];i++) {
      fwrite(&rp[p].puntos[i].x, sizeof(int), 1, f);
      fwrite(&rp[p].puntos[i].y, sizeof(int), 1, f);
      fwrite(&rp[p].marcado[i], sizeof(int), 1, f);
    }
  }
}

int readFile(FILE * f, Examen ex , ResultadoPagina * rp){
  int n_paginas;
  int n_items;
  int x,y,m;
  int res = fread(& n_paginas, sizeof(int), 1, f);
  if (res > 0) {
    for (int p=0 ; p < n_paginas ; p++) {
      fread(&n_items, sizeof(int), 1, f);
      rp[p].puntos  = (CvPoint *) malloc(n_items  * sizeof(CvPoint));
      rp[p].marcado = (int *)     calloc(n_items  , sizeof(int));
      for (int i=0; i < n_items;i++) {
        fread(&x, sizeof(int), 1, f);
        fread(&y, sizeof(int), 1, f);
        fread(&m, sizeof(int), 1, f);
        rp[p].puntos[i] = cvPoint(x,y);
        rp[p].marcado[i] = m;
      }
    }
  }
  return res;
}
/******************************************************************************/

int cstring_cmp(const void *a, const void *b){ 
  const char **ia = (const char **)a;
  const char **ib = (const char **)b;
  return strcmp(*ia, *ib);
}


void configuraControl1(Examen * ex){
  ex->n_paginas = 5;
  ex->n_items [0]  = 24;
  ex->n_items [1]  = 24;
  ex->n_items [2]  = 20;
  ex->n_items [3]  = 8;
  ex->n_items [4]  = 4;  
  
  
  
  // desde punto inferior izquierda hasta punto superior derecho
  ex->pos_respuestas[0] = cvRect( 200, 400,  85,1700);
  ex->pos_respuestas[1] = cvRect( 200, 200,  85,2000);
  ex->pos_respuestas[2] = cvRect( 200, 240,  85,1600);
  ex->pos_respuestas[3] = cvRect( 200, 300,  85, 700);    
  ex->pos_respuestas[4] = cvRect( 200,1200,  85, 400);
    
  ex->respuestas[0][0]  = 1;
  ex->respuestas[0][5]  = 1;
  ex->respuestas[0][11] = 1;
  ex->respuestas[0][15] = 1;  
  ex->respuestas[0][16] = 1;  
  ex->respuestas[0][22] = 1;  
    
  ex->respuestas[1][1] = 1;
  ex->respuestas[1][5] = 1;
  ex->respuestas[1][10] = 1;
  ex->respuestas[1][15] = 1;
  ex->respuestas[1][16] = 1;
  ex->respuestas[1][23] = 1;
  
  
  ex->respuestas[2][3] = 1;
  ex->respuestas[2][7] = 1;
  ex->respuestas[2][11] = 1;
  ex->respuestas[2][12] = 1;
  ex->respuestas[2][16] = 1;
 
  
  ex->respuestas[3][3] = 1;
  ex->respuestas[3][6] = 1;

  ex->respuestas[4][0] = 1;

  for (int p=0; p < 5 ; p++)
    for (int i=0; i < ex->n_items [p];i++) 
      ex->itemsPregunta[p][i] = (i/4)+1;
}


void configuraControl2(Examen * ex){
  ex->n_paginas = 6;
  ex->n_items [0]  = 20;
  ex->n_items [1]  = 20;
  ex->n_items [2]  = 17;
  ex->n_items [3]  = 8;
  ex->n_items [4]  = 8;  
  ex->n_items [5]  = 8;  
  
  
  // desde punto inferior izquierda hasta punto superior derecho
  ex->pos_respuestas[0] = cvRect( 190, 370,  75,1600);
  ex->pos_respuestas[1] = cvRect( 190, 240,  75,1500);
  ex->pos_respuestas[2] = cvRect( 190, 240,  75,1200);
  ex->pos_respuestas[3] = cvRect( 190,1100,  75, 600);    
  ex->pos_respuestas[4] = cvRect( 190,1250,  75, 700);
  ex->pos_respuestas[5] = cvRect( 190, 220,  75, 900);  

  ex->respuestas[0][2]  = 1;
  ex->respuestas[0][5]  = 1;
  ex->respuestas[0][8] = 1;
  ex->respuestas[0][14] = 1;  
  ex->respuestas[0][16] = 1;  
  
  ex->respuestas[1][0] = 1;
  ex->respuestas[1][4] = 1;
  ex->respuestas[1][11] = 1;
  ex->respuestas[1][15] = 1;
  ex->respuestas[1][18] = 1;
   
  ex->respuestas[2][2] = 1;
  ex->respuestas[2][6] = 1;
  ex->respuestas[2][9] = 1;
  ex->respuestas[2][15] = 1;
  
  ex->respuestas[3][3] = 1;
  ex->respuestas[3][6] = 1;

  ex->respuestas[4][1] = 1;
  ex->respuestas[4][4] = 1;

  ex->respuestas[5][2] = 1;
  ex->respuestas[5][5] = 1;

  for (int p=0; p < 6 ; p++)
    for (int i=0; i < ex->n_items [p];i++)
      ex->itemsPregunta[p][i] = (i/4)+1;
  ex->itemsPregunta[2][8] = 2;
  ex->itemsPregunta[2][12] = 3;
  ex->itemsPregunta[2][16] = 4;
}

void leer_directorio(const char* nombre_directorio,const char* extension, int * numero_ficheros ,char ** ficheros){
  int            tam;
  DIR            * directorio;
  char           * extension_fichero;
  struct dirent  * dit;
  
  *numero_ficheros = 0;

  if ((directorio = opendir(nombre_directorio )) == NULL) {
    perror("opendir");
    return;
  }

  while ((dit = readdir(directorio)) != NULL){
    
    tam = strlen(dit->d_name);
    extension_fichero = &(dit->d_name[tam-strlen(extension)]);
    
    if ( strcmp(extension, extension_fichero) == 0  )  {
      ficheros [*numero_ficheros] = strdup(dit->d_name);      
      (*numero_ficheros)++;
    }
    
  }

  if (closedir(directorio) == -1) {
    perror("closedir");
    return;
  }

  qsort(ficheros, *numero_ficheros, sizeof(char *), cstring_cmp);
}

int main( int argc, char** argv ){
  int c;
  int flagL= 0;
  int flagC= 0;       
  int flagP= 0;       
  
  while ((c = getopt (argc, argv, "plc?")) != -1)
    switch (c)
      {
      case 'p':
        printf ("-p preproceso \n");
	flagP= 1;
	break;
      case 'l':
	printf ("-l lectura \n");
	flagL= 1;
	break;
      case 'c':
	printf ("-c correccion \n");
	flagC= 1;
	break;
      case '?':

	printf("Uso: ACT.bin  <options>\n\n");
	printf("opciones:\n");
        printf(" -p : preprocesar examenes.\n");
	printf(" -l : lectura de los examenes.\n");
	printf(" -c : correccion de los examenes\n");
	printf(" -? : ayuda.\n\n");
	return 1;
    }

  struct Examen ex; 
  configuraControl1(&ex);

  
  
  int numero_ficheros;
  

  FILE * registroPuntos;
  




  int contador_examenes;
  struct ResultadoPagina * rp;
  rp = (ResultadoPagina *) malloc( ex.n_paginas * sizeof(ResultadoPagina) );
  for (int j = 0; j< ex.n_paginas; j++) {
    rp[j].puntos  = (CvPoint *) malloc(ex.n_items [j] * sizeof(CvPoint));
    rp[j].marcado = (int *) calloc(ex.n_items [j] , sizeof(int));
  }

  char * ficheros [MAX_FILES];
  char   fichero  [MAX_LEN_FILENAME];
  //Preprocesado
  leer_directorio("./ExamenesOriginal/\0",".jpg\0",&numero_ficheros,ficheros);
  if (flagP){
    for (int j = 0; j < numero_ficheros  ; j++) {
      sprintf(fichero,"./ExamenesOriginal/%s\0",ficheros[j]);
      prepararImagen (fichero, j/ex.n_paginas, j%ex.n_paginas);
    }
  }
  
  //Lectura de imagenes
  leer_directorio("./ExamenesPreparados/\0",".jpg\0",&numero_ficheros,ficheros);
  if (flagL){
    if((registroPuntos = fopen("registroPuntos.txt", "wb"))==NULL) {
      printf("Cannot open file.\n");
      exit(1);
    }
    
    FILE * registro_incidencias;
    if((registro_incidencias = fopen("registroIncidencias.txt", "wb"))==NULL) {
      printf("Cannot open file.\n");
      exit(1);
    }
    int items_capturados;

    
    for (int j = 0; j < numero_ficheros  ; j++) {
      sprintf(fichero,"./ExamenesPreparados/%s\0",ficheros[j]);
      items_capturados = leePaginaExamen(fichero,ex.pos_respuestas[j%ex.n_paginas] , ex.n_items[j%ex.n_paginas] ,rp[j%ex.n_paginas]);
      writeFile(registroPuntos,ex,rp);
      fflush(registroPuntos);      
      
      if (items_capturados) 
        fprintf(registro_incidencias,"Incidencia en examen %d pagina %d: Items encontrados %d de %d \n\0", j/ex.n_paginas,(j%ex.n_paginas)+1,items_capturados, ex.n_items[j%ex.n_paginas]);
      
      
      if ( (j+1) % ex.n_paginas == 0)  {
        for (int k = 0; k< ex.n_paginas; k++) {
	  free(rp[k].marcado );
	  rp[k].marcado = (int *) calloc(ex.n_items [k] , sizeof(int));
        }
      }
    }
    fclose(registroPuntos);
    fclose(registro_incidencias);
  }
  
  
  //Correccion de examenes
  int continua_fichero;
  if (flagC) {
    if((registroPuntos = fopen("registroPuntos.txt", "rb"))==NULL) {
      printf("Cannot open file.\n");
      exit(1);
    }
    
    continua_fichero = readFile (registroPuntos,ex,rp);
    for (int j = 0; continua_fichero  ; j++) {     
      corrijeExamen(ex, j/ex.n_paginas,rp);     
      continua_fichero = readFile (registroPuntos,ex,rp);
    }
    
    fclose(registroPuntos);
  }
  
  /*

  for (int j = 0; j< numero_ficheros  ; j++) {
    //Comenzamos a leer un examen
    if ( j % ex.n_paginas == 0)   printf("Examen n: %d \n",j/ex.n_paginas);
    sprintf(file,"./ExamenesOriginal/%s\0",ficheros[j]);

    if (flagL) leePaginaExamen(file,ex.origen[j%ex.n_paginas], ex.destino[j%ex.n_paginas] , ex.n_items[j%ex.n_paginas] ,rp[j%ex.n_paginas]);

    //Termino de extraer puntos de un examen entero
    if ( (j+1) % ex.n_paginas == 0)  {
      if (flagL) {
	writeFile(registroPuntos,ex,rp);
	fflush(registroPuntos);
      }
      else readFile (registroPuntos,ex,rp);
          
      corrijeExamen(ex, j/ex.n_paginas,rp);
      for (int j = 0; j< ex.n_paginas; j++) {
	free(rp[j].marcado );
	rp[j].marcado = (int *) calloc(ex.n_items [j] , sizeof(int));
      }

    }
  }
*/

  return 0;
}

