/*
 * main.c
 *
 * Code generation for function 'main'
 *
 */

/*************************************************************************/
/* This automatically generated example C main file shows how to call    */
/* entry-point functions that MATLAB Coder generated. You must customize */
/* this file for your application. Do not modify this file directly.     */
/* Instead, make a copy of this file, modify it, and integrate it into   */
/* your development environment.                                         */
/*                                                                       */
/* This file initializes entry-point function arguments to a default     */
/* size and value before calling the entry-point functions. It does      */
/* not store or use any values returned from the entry-point functions.  */
/* If necessary, it does pre-allocate memory for returned values.        */
/* You can use this file as a starting point for a main function that    */
/* you can deploy in your application.                                   */
/*                                                                       */
/* After you copy the file, and before you deploy it, you must make the  */
/* following changes:                                                    */
/* * For variable-size function arguments, change the example sizes to   */
/* the sizes that your application requires.                             */
/* * Change the example values of function arguments to the values that  */
/* your application requires.                                            */
/* * If the entry-point functions return values, store these values or   */
/* otherwise use them as required by your application.                   */
/*                                                                       */
/*************************************************************************/

/* Include files */
#include "main.h"
#include "pcaRed.h"
#include "pcaRed_emxAPI.h"
#include "pcaRed_terminate.h"
#include "pcaRed_types.h"
#include "rt_nonfinite.h"

/* Function Declarations */
static emxArray_real_T *argInit_d1000000xd12_real_T(void);

static double argInit_real_T(void);

/* Function Definitions */
static emxArray_real_T *argInit_d1000000xd12_real_T(void)
{
  emxArray_real_T *result;
  double *result_data;
  int idx0;
  int idx1;
  /* Set the size of the array.
Change this size to the value that the application requires. */
  result = emxCreate_real_T(2, 2);
  result_data = result->data;
  /* Loop over the array to initialize each element. */
  for (idx0 = 0; idx0 < result->size[0U]; idx0++) {
    for (idx1 = 0; idx1 < result->size[1U]; idx1++) {
      /* Set the value of the array element.
Change this value to the value that the application requires. */
      result_data[idx0 + result->size[0] * idx1] = argInit_real_T();
    }
  }
  return result;
}

static double argInit_real_T(void)
{
  return 0.0;
}

int main(int argc, char **argv)
{
  (void)argc;
  (void)argv;
  /* The initialize function is being called automatically from your entry-point
   * function. So, a call to initialize is not included here. */
  /* Invoke the entry-point functions.
You can call entry-point functions multiple times. */
  main_pcaRed();
  /* Terminate the application.
You do not need to do this more than one time. */
  pcaRed_terminate();
  return 0;
}

void main_pcaRed(void)
{
  emxArray_real_T *data;
  emxArray_real_T *dataRed;
  /* Initialize function 'pcaRed' input arguments. */
  /* Initialize function input argument 'data'. */
  data = argInit_d1000000xd12_real_T();
  /* Call the entry-point 'pcaRed'. */
  emxInitArray_real_T(&dataRed, 2);
  pcaRed(data, dataRed);
  emxDestroyArray_real_T(data);
  emxDestroyArray_real_T(dataRed);
}

/* End of code generation (main.c) */
