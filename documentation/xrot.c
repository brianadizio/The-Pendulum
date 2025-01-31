/*
 * xrot.c
 *
 * Code generation for function 'xrot'
 *
 */

/* Include files */
#include "xrot.h"
#include "pcaRed_types.h"
#include "rt_nonfinite.h"

/* Function Definitions */
void xrot(int n, emxArray_real_T *x, int ix0, int iy0, double c, double s)
{
  double *x_data;
  int k;
  x_data = x->data;
  if (n >= 1) {
    for (k = 0; k < n; k++) {
      double b_temp_tmp;
      double temp_tmp;
      int b_temp_tmp_tmp;
      int temp_tmp_tmp;
      temp_tmp_tmp = (iy0 + k) - 1;
      temp_tmp = x_data[temp_tmp_tmp];
      b_temp_tmp_tmp = (ix0 + k) - 1;
      b_temp_tmp = x_data[b_temp_tmp_tmp];
      x_data[temp_tmp_tmp] = c * temp_tmp - s * b_temp_tmp;
      x_data[b_temp_tmp_tmp] = c * b_temp_tmp + s * temp_tmp;
    }
  }
}

/* End of code generation (xrot.c) */
