#include <stdio.h>
#include <math.h>
#define PI 3.1415926535  //defining a global variable for the value of pi

//start ----------------------------------------------------------------------------------------------------------//

//defining 2 functionf for h1 and h2 

void h1(double t, double * h1_Re, double * h1_Im)  //Makes use of pointers
  {

    * h1_Re = cos(t) + cos(5*t);                   //real part of h1
    * h1_Im = sin(t) + sin(5*t);                   //imaginary part of h1

    //printf("h1: %f + %f i\n", *h1_Re, *h1_Im);     
  }

void h2(double t, double * h2_Re, double * h2_Im )
  {
    double part = (t - PI)*(t - PI);
    double power = part / 2 ;
    * h2_Re = exp(power);    //real part of h2
    * h2_Im  = 0;           //imaginary part of h2

    //printf("h2: %f + %f i\n", *h2_Re, *h2_Im);  
  }
 
 //function for the exponential part of fourier transforms
 void exponential(double k, double n, double * t, double * exp_real, double * exp_im)
   {
       *t = k * ((2 * PI) /100);
       * exp_real = cos ((*t) * (n));
       * exp_im = - sin ((*t) * (n));
   }

//--------------------------------------------------------------------------------------------------------------------//

// writing the sampled results (with N = 100) into files named 'h1_data.txt' and 'h2_data.txt'

void h1_txt_file()
 {
    FILE *fp; // declare a pointer to FILE fp
    fp = fopen("h1_data.txt", "w");
    int k = 0;

    for (k = 0; k < 100; k++)
    {
        double h1_Re, h1_Im;
        double t = k * ((2 * PI) /100);    // t is time
        h1(t, &h1_Re, &h1_Im);
        fprintf(fp, "%f %f %f\n", t, h1_Re, h1_Im);
    }
    fclose(fp);
 }


 void h2_txt_file()
  {
    FILE *fp; // declare a pointer to FILE fp
    fp = fopen("h2_data.txt", "w");
    int k = 0;

    for (k = 0; k < 100; k++)
    {
        double h2_Re, h2_Im;
        double t = k * ((2 * PI) /100);
        h2(t, &h2_Re, &h2_Im);
        fprintf(fp, "%f %f %f\n", t, h2_Re, h2_Im);
    }
    fclose(fp);
  }

// -----------------------------------------------------------------------------------------------------------------------------------//

// Using discrete fourier analysis for function h1 and h2
void fourier_analysis () 
  {   
    // H1 - fourier transform for h1

    printf("\n");
    printf("Printing fourier transform of h1:\n");
    printf("\n");
    
    //define all variables 
    double t, Real_1, Real_2, Imaginary_1, Imaginary_2; 
    double  H1_Re, H1_Im;

    // Real1 and Imaginary1 refer to the real/ imaginary part of the function.
    // Real2 and Imaginary2 refer to the real/ imaginary part of the exponential in the fourier series. 

    double real, imaginary;                    //for summations
    double array_H1_Re[100], array_H1_Im[100]; //store results in an array
    int k, n;                                  // for iterations

    for(n = 0; n < 100; n ++)
    {
        real = 0;                            //set the summation back to 0 after each iteration of n
        imaginary = 0;

        for(k = 0; k < 100; k++)
        {

            exponential(k, n, &t, &Real_2, &Imaginary_2);
            h1(t, &Real_1, &Imaginary_1);

            H1_Re = (Real_1 * Real_2) - (Imaginary_1 * Imaginary_2); 
            H1_Im = (Real_1 * Imaginary_2) + (Imaginary_1 * Real_2); 
            real += H1_Re;
            imaginary += H1_Im;
        }
        array_H1_Re[n] = real;                          //iterate results to an array to access the values
        array_H1_Im[n] = imaginary; 
        printf("for n = %d, H1_Re = %f, H1_Im = %f\n", n, real, imaginary);                 //REMEMBER TO UNCOMMENT THIS LINE

    }

    //H2 - fourier transform for h2

    printf("\n");
    printf("Printing fourier transform of h2:\n");
    printf("\n");

    double H2_Re, H2_Im, h2_Re, h2_Im;
    double array_H2_Re[100], array_H2_Im[100];

    for(n = 0; n < 100; n ++)
    {
        real = 0;
        imaginary = 0;
        
        for(k = 0; k < 100; k++)
        {
            exponential(k, n, &t, &Real_2, &Imaginary_2);
            h2(t, &h2_Re, &h2_Im);

            H2_Re = h2_Re * Real_2;
            H2_Im = h2_Im * Imaginary_2;
            real += H2_Re;
            imaginary = H2_Im ;
        }

        array_H2_Re[n] = real;                                
        array_H2_Im[n] = imaginary;
        printf("for n = %d, H2_Re = %f, H2_Im = %f\n", n, real, imaginary);                                  //REM TO UNCOMMENT
    }
    //for(int loop = 0; loop < 100; loop++)
     //{printf("%f\n", array_1_Re[loop]);}           //code for checking the array is done correctly

   //-----------------------------------------------------------------------------------------------//

   // inverse transform
   // h1'

   FILE *fp; // declare a pointer to FILE fp
   fp = fopen("h1'_data.txt", "w");
   fprintf(fp, "k t Real Imaginary\n");

    for(k = 0; k < 100; k ++)
      {
        real = 0;
        imaginary = 0;

        for(n = 0; n < 100  ; n ++)
        {
            if (n !=  1)
            {
                double H1_Re_inv, H1_Im_inv;   //Real_1, Imaginary1, 
                exponential(k, n, &t, &Real_2, &Imaginary_2);
                Real_1 = array_H1_Re[n];
                Imaginary_1 = array_H1_Im[n];

                H1_Re_inv = (Real_1 * Real_2) - (Imaginary_1 *  - Imaginary_2);
                H1_Im_inv = (Real_1 * - Imaginary_2) + (Imaginary_1 * Real_2); 
                real += H1_Re_inv;
                imaginary += H1_Im_inv;
            }
        }
        fprintf(fp, "%d %f %f %f\n", k, t, real/100, imaginary/100);
        //printf("\nfor k = %d, t = %f: H1_Re_inv = %f, H1_Im_inv = %f", k, t, real/100, imaginary/100);
      }

    fclose(fp);

    // h2'

   FILE *fp_h2; // declare a pointer to FILE fp
   fp_h2 = fopen("h2'_data.txt", "w");
   fprintf(fp_h2, "k t Real Imaginary\n");

    for(k = 0; k < 100; k ++)
      {
        real = 0;
        imaginary = 0;

        for(n = 1; n < 100  ; n ++)
        {
                double H1_Re_inv, H1_Im_inv;

                exponential(k, n, &t, &Real_2, &Imaginary_2);

                Real_1 = array_H2_Re[n];
                Imaginary_1 = array_H2_Im[n];
                H1_Re_inv = (Real_1 * Real_2) - (Imaginary_1 * - Imaginary_2);
                H1_Im_inv = (Real_1 * - Imaginary_2) + (Imaginary_1 * Real_2); 
                real += H1_Re_inv;
                imaginary += H1_Im_inv;
        }
        
        fprintf(fp_h2, "%d %f %f %f\n", k, t, real/100, imaginary/100);
        //printf("for k = %d, t = %f: H2_Re_inv = %f, H2_Im_inv = %f\n", k, t, real/100, imaginary/100);
        
      }

    fclose(fp_h2);
  }

//-----------------------------------------------------------------------------------------------------------------------------------

void h3_analysis()
  {
    FILE *fp;
    double t, re, im;
    double h3_array[200][3];  //define a 2D array which stores the real and imaginary parts
    fp = fopen("h3.txt", "r");
    int n, k = 0;
    while(fscanf(fp, "%d%*c  %le%*c %le%*c %le", &n, &t, &re, &im) != EOF)    //*c tells the scan statement to omit the comma 

    {
        h3_array[k][0] = t;
        h3_array[k][1] = re;
        h3_array[k][2] = im;

        //printf("%le, %le, %le\n", h3_array[k][0], h3_array[k][1], h3_array[k][2]);
        k ++;
    }
    fclose(fp);

//------------------------------------------------------------------------------------------------
    //H3
    printf("\n");

    double H1_Re, H1_Im, Real_1, Real_2, Imaginary_1, Imaginary_2; 
    double real, imaginary;
    double array_1_Re[200], array_1_Im[200];
    
    for(n = 0; n < 200; n ++)
    {
        real = 0;
        imaginary = 0;

        for(k = 0; k < 200; k++)
        {
            //exponential(k, n, &t, &Real_2, &Imaginary_2);
            double t = h3_array[k][0];
            Real_1 = h3_array[k][1];
            Imaginary_1 = h3_array[k][2];
            Real_2 = cos(t * n);
            Imaginary_2 = -sin(t * n);
            H1_Re = (Real_1 * Real_2) - (Imaginary_1 * Imaginary_2);
            H1_Im = (Real_1 * Imaginary_2) + (Imaginary_1 * Real_2); 
            real += H1_Re;
            imaginary += H1_Im;
        }
        array_1_Re[n] = real; 
        array_1_Im[n] = imaginary; 
        //printf("for n = %d, H3_Re = %f, H3_Im = %f\n", n, real, imaginary);       
    }
  
  //---------------------------------------------------------------------------------
  //inverse of H3
    FILE *inverse_fp; // declare a pointer to FILE inverse_fp
    inverse_fp = fopen("h3'_data.txt", "w");
    fprintf(inverse_fp, "k Real Imaginary\n");

     for(k = 0; k < 200; k ++)
      {
        real = 0;
        imaginary = 0;

        for(n = 0; n < 200; n++)
        {
           if (n ==  1 || n == 3 || n== 4 || n == 13 )
            {
                
                double t = h3_array[k][0];
                Real_2 = cos(t *n );
                Imaginary_2 = sin(t *n );
                double Real_1 = array_1_Re[n];
                double Imaginary_1 = array_1_Im[n];
                double H3_Re_inv = (Real_1 * Real_2) - (Imaginary_1 * - Imaginary_2);
                double H3_Im_inv = (Real_1 * - Imaginary_2) + (Imaginary_1 * Real_2); 
                real += H3_Re_inv;
                imaginary += H3_Im_inv;
            }
        }
        //printf("for k = %d, H3_Re_inv = %f, H3_Im_inv = %f\n", k, real/200, imaginary/200);
        fprintf(inverse_fp, "%d %f %f\n", k, real/200, imaginary/200);                  
      }

      fclose(inverse_fp);
  }

int main()
  {
      h1_txt_file();
      h2_txt_file();
      fourier_analysis();
      h3_analysis();
  }
