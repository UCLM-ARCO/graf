import cv
import opencv
import math
#constantes
classes = 10
train_samples = 50
size = 40
trainData    = cv.CreateMat(train_samples*classes, size*size, cv.CV_32FC1)
trainClasses = cv.CreateMat(train_samples*classes, 1, cv.CV_32FC1)
K=10;
#constantes

def estaMarcada( marcadog , punto, ancho):
  sub = cv.GetSubRect(marcadog, (punto[0], punto[1], ancho, ancho))
  media = cv.Avg(sub)
  print "Media para punto"+ str(punto) +": " + str(cv.Avg(sub))
  opencv.cvReleaseImage(sub)
  if media[0] < 250:
    return True
  else:
    return False

def puntosParaTemplate (imagen, template):
  res_width  = imagen.width - template.width + 1;
  res_height = imagen.height - template.height + 1;
  resultado  = cv.CreateImage( ( res_width, res_height ), cv.IPL_DEPTH_32F, 1 )
  cv.MatchTemplate(imagen,template,resultado, cv.CV_TM_SQDIFF)
  pos = []
  eig_image = cv.CreateMat(imagen.rows, imagen.cols, cv.CV_32FC1)
  temp_image = cv.CreateMat(imagen.rows, imagen.cols, cv.CV_32FC1)
  for (x,y) in cv.GoodFeaturesToTrack(resultado, eig_image, temp_image, 0, 0.2, template.width, useHarris = True):
    pos.append((x,y)) 
  pos =  sorted(pos)
  opencv.cvReleaseImage(resultado)
  opencv.cvReleaseImage(eig_image)
  opencv.cvReleaseImage(temp_image)  
  return pos

###########################################################################    
####################################OCR####################################    
###########################################################################
def findX(imgSrc):
  mini = 0
  maxi = 0
  minFound = 0
  maxVal=cv.RealScalar(imgSrc.width * 255)
  for i in range(0,imgSrc.width):
    data = cv.GetCol(imgSrc, i);
    val  = cv.Sum(data);
    if(val[0] < maxVal[0]):
      maxi = i
      if(not minFound):
        mini = i
	minFound= 1
  return mini,maxi

def findY(imgSrc):
  mini = 0
  maxi = 0
  minFound = 0
  maxVal=cv.RealScalar(imgSrc.width * 255)
  for i in range(0,imgSrc.height):
    data = cv.GetRow(imgSrc, i);
    val  = cv.Sum(data);
    if(val[0] < maxVal[0]):
      maxi = i
      if(not minFound):
        mini = i
	minFound= 1
  return mini,maxi
      
def findBB(imgSrc):
  xmin,xmax = findX(imgSrc)
  ymin,ymax = findY(imgSrc)
  return (xmin, ymin, xmax-xmin, ymax-ymin);

def preprocessing(imgSrc,new_width, new_height):
  bb = findBB(imgSrc)
  data = cv.GetSubRect(imgSrc, (bb[0] ,bb[1] , bb[2], bb[3]) )
  
  if bb[2]>bb[3]:
    size = bb[2]
  else:
    size = bb[3]
  
  result = cv.CreateImage( ( size, size), 8, 1 )
  cv.Set(result,255);
  #Copy de data in center of image
  x = int(math.floor(float((size-bb[2]))/2.0))
  y = int(math.floor(float((size-bb[3]))/2.0))
  dataA = cv.GetSubRect(result,(x,y,bb[2], bb[3]))
  cv.Copy(data, dataA);
  #Scale result
  scaledResult = cv.CreateImage( ( new_width, new_height ), 8, 1 );
  cv.Resize(result, scaledResult, cv.CV_INTER_NN);


  return scaledResult
  


def getData():

  for i in range (0 , classes):
    for j in range (0, train_samples):
      if j < 10 :
        fichero = "OCR/"+str(i) + "/"+str(i)+"0"+str(j)+".pbm"
      else:
        fichero = "OCR/"+str(i) + "/"+str(i)+str(j)+".pbm"
      src_image = cv.LoadImage(fichero,0)
      prs_image = preprocessing(src_image, size, size)
  
         
      
      row = cv.GetRow(trainClasses, i*train_samples + j)
      cv.Set(row, cv.RealScalar(i))
      row = cv.GetRow(trainData,   i*train_samples + j)

      img = cv.CreateImage( ( size, size ), cv.IPL_DEPTH_32F, 1) 
      

      cv.ConvertScale(prs_image,img,0.0039215, 0)


      data = cv.GetSubRect(img,  (0,0, size,size))
      row1 = cv.Reshape( data, 0, 1 )
     
      cv.Copy(row1, row)


def train():
  knn = opencv.CvKNearest( )
  
  #knn.train(knn,trainData, trainClasses, 0, False, K)
  #return knn
  #return opencv.CvKNearest( trainData, trainClasses )
  #return opencv.CvKNearest( trainData, trainClasses, 0 )
  #return opencv.CvKNearest( trainData, trainClasses, 0, False  )
  #return opencv.CvKNearest( trainData, trainClasses, 0, False, K )
  return knn

#     CvKNearest(CvMat const *,CvMat const *,CvMat const *,bool,int)
#     CvKNearest(CvMat const *,CvMat const *,CvMat const *,bool)
#     CvKNearest(CvMat const *,CvMat const *,CvMat const *)
#     CvKNearest(CvMat const *,CvMat const *)


def classify(img):
  nearest=cv.CreateMat(1,K,cv.CV_32FC1)
  prs_image = preprocessing(img, size, size)
  
  img32  = cv.CreateImage( ( size, size ), cv.IPL_DEPTH_32F, 1 )
  cv.ConvertScale(prs_image, img32, 0.0039215, 0)
  data   = cv.GetSubRect(img32,  (0,0, size,size))
  row1   = cv.Reshape( data, 0, 1 )
  result = knn.find_nearest(nearest,row1,K,0,0,0)	
  result = 0
  
  indices = cv.Mat(N, K, cv.CV_32S)
  dists = cv.Mat(N, K, cv.CV_32F)

  flann.knnSearch(m_object, indices, dists, K, cv.SearchParams(250))
    
  
  accuracy=0
  for i in range (0,K):
  #  print nearest
   # if  nearest.data.fl[i] == result:
    accuracy+=1

    pre= 100*(float(accuracy)/float(K))
   
  #print "r: ",result," pre ",pre," accu ",accuracy," K ",K
  return result


def test():
  error = 0
  testcount = 0
  for i in range (0 , classes):
   for j in range (0, train_samples):
     if j < 10 :
       fichero = "OCR/"+str(i) + "/"+str(i)+"0"+str(j)+".pbm"
     else:
       fichero = "OCR/"+str(i) + "/"+str(i)+str(j)+".pbm"
     src_image = cv.LoadImage(fichero,0)
     prs_image = preprocessing(src_image, size, size)

     r=classify(prs_image);
     if(not int(r)==i):
       error+=1
     testcount+=1
  totalerror=100*float(error)/float(testcount)
  print "System Error: ", totalerror
      

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
####################################OCR####################################    
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	


print "Aprendizaje--"

#getData()
#knn = train()
#test()
print "Fin aprendizaje--"
    
    
marcado  = cv.LoadImageM("e01.jpg", cv.CV_LOAD_IMAGE_GRAYSCALE)
marcadog = cv.LoadImageM("e01.jpg", cv.CV_LOAD_IMAGE_GRAYSCALE)
itemP    = cv.LoadImageM("itemP.jpg", cv.CV_LOAD_IMAGE_GRAYSCALE)
itemH    = cv.LoadImageM("itemH.jpg", cv.CV_LOAD_IMAGE_GRAYSCALE)



puntos_horizontales  = puntosParaTemplate (marcado, itemH)

print "horizontales: " + str (puntos_horizontales .__len__())

x1 = puntos_horizontales[0][0]
y1 = marcado.height-puntos_horizontales[0][1]

x2 = puntos_horizontales[1][0]
y2 = marcado.height-puntos_horizontales[1][1]

rot_mat = cv.CreateMat(2, 3, cv.CV_32F)
ang_rad = math.atan((y2-y1)/(x2-x1))
degrees = - (180 * ang_rad / math.pi)
cv.GetRotationMatrix2D( (marcado.width/2,marcado.height/2), degrees, 1, rot_mat );
cv.WarpAffine( marcado, marcadog, rot_mat );
opencv.cvReleaseImage(marcado)


puntos_horizontales  = puntosParaTemplate (marcado, itemH)
pos_respuesta  = puntosParaTemplate (marcadog, itemP)




print "respuestas: " + str (pos_respuesta.__len__())
#print "horizontal: " + str (pos_horizontal.__len__())
#print "sin marcar: " + str (sin_marcar.__len__())


for i in pos_respuesta:
#  punto1 = (pos_horizontal[0][0]     ,i[1]   )
#  punto2 = (pos_horizontal[0][0]+17  ,i[1]+17)
  punto1 = (i[0]+3     ,i[1]+2  )
  punto2 = (i[0]+27    ,i[1]+27)
  if  estaMarcada( marcadog , punto1, 26 ):
    cv.Rectangle ( marcadog , punto1, punto2 , cv.Scalar( 0, 0, 255, 0 ) , 1, 0, 0 )


punto = puntos_horizontales[1]

#cv.Rectangle ( marcadog ,(punto[0]-57,punto[1]+2), (punto[0]+32,punto[1]+35) , cv.Scalar( 0, 0, 255, 0 ) , 1, 0, 0 )

punto = (punto[0]-57, punto[1]+2)
for i in range (0,8):

  cv.Rectangle ( marcadog , punto, (punto[0]+32,punto[1]+34) , cv.Scalar( 0, 0, 255, 0 ) , 1, 0, 0 )
  punto = (punto[0]-55.5, punto[1])
  
cv.SaveImage("correc.jpg", marcadog)
opencv.cvReleaseImage(marcadog)
opencv.cvReleaseImage(itemP)
opencv.cvReleaseImage(itemH)



#cv.NamedWindow( "reference", cv.CV_WINDOW_AUTOSIZE );
#cv.ShowImage( "reference", marcadog );
#cv.WaitKey( 0 );
#cv.DestroyWindow( "reference" );


