/*
 * pcaRed.c
 *
 * Code generation for function 'pcaRed'
 *
 */

/* Include files */
#include "pcaRed.h"
#include "pca.h"
#include "pcaRed_emxutil.h"
#include "pcaRed_types.h"
#include "rt_nonfinite.h"

/* Function Definitions */
void pcaRed(const emxArray_real_T *data, emxArray_real_T *dataRed)
{
  emxArray_real_T *b_data;
  emxArray_real_T *b_dataRed;
  double coef_data[144];
  const double *data_data;
  double *b_data_data;
  double *dataRed_data;
  int coef_size[2];
  int i;
  int i1;
  int loop_ub;
  data_data = data->data;
  emxInit_real_T(&b_data, 2);
  i = b_data->size[0] * b_data->size[1];
  b_data->size[0] = data->size[0];
  b_data->size[1] = data->size[1];
  emxEnsureCapacity_real_T(b_data, i);
  b_data_data = b_data->data;
  loop_ub = data->size[0] * data->size[1] - 1;
  for (i = 0; i <= loop_ub; i++) {
    b_data_data[i] = data_data[i];
  }
  emxInit_real_T(&b_dataRed, 2);
  local_pca(b_data, data->size[1], coef_data, coef_size, b_dataRed);
  b_data_data = b_dataRed->data;
  emxFree_real_T(&b_data);
  i = dataRed->size[0] * dataRed->size[1];
  dataRed->size[0] = b_dataRed->size[0];
  dataRed->size[1] = 3;
  emxEnsureCapacity_real_T(dataRed, i);
  dataRed_data = dataRed->data;
  loop_ub = b_dataRed->size[0];
  for (i = 0; i < 3; i++) {
    for (i1 = 0; i1 < loop_ub; i1++) {
      dataRed_data[i1 + dataRed->size[0] * i] =
          b_data_data[i1 + b_dataRed->size[0] * i];
    }
  }
  emxFree_real_T(&b_dataRed);
}

/* End of code generation (pcaRed.c) */
