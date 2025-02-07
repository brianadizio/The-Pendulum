/*
 * pca.h
 *
 * Code generation for function 'pca'
 *
 */

#ifndef PCA_H
#define PCA_H

/* Include files */
#include "pcaRed_types.h"
#include "rtwtypes.h"
#include <stddef.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
void local_pca(emxArray_real_T *x, int NumComponents, double coeffOut_data[],
               int coeffOut_size[2], emxArray_real_T *scoreOut);

#ifdef __cplusplus
}
#endif

#endif
/* End of code generation (pca.h) */
