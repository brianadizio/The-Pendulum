/*
 * xdotc.c
 *
 * Code generation for function 'xdotc'
 *
 */

/* Include files */
#include "xdotc.h"
#include "pcaRed_types.h"
#include "rt_nonfinite.h"

/* Function Definitions */
double xdotc(int n, const emxArray_real_T *x, int ix0, const emxArray_real_T *y,
             int iy0)
{
  const double *x_data;
  const double *y_data;
  double d;
  int k;
  y_data = y->data;
  x_data = x->data;
  d = 0.0;
  if (n >= 1) {
    for (k = 0; k < n; k++) {
      d += x_data[(ix0 + k) - 1] * y_data[(iy0 + k) - 1];
    }
  }
  return d;
}

/* End of code generation (xdotc.c) */
