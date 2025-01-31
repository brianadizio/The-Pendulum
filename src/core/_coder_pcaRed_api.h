/*
 * _coder_pcaRed_api.h
 *
 * Code generation for function 'pcaRed'
 *
 */

#ifndef _CODER_PCARED_API_H
#define _CODER_PCARED_API_H

/* Include files */
#include "emlrt.h"
#include "mex.h"
#include "tmwtypes.h"
#include <string.h>

/* Type Definitions */
#ifndef struct_emxArray_real_T
#define struct_emxArray_real_T
struct emxArray_real_T {
  real_T *data;
  int32_T *size;
  int32_T allocatedSize;
  int32_T numDimensions;
  boolean_T canFreeData;
};
#endif /* struct_emxArray_real_T */
#ifndef typedef_emxArray_real_T
#define typedef_emxArray_real_T
typedef struct emxArray_real_T emxArray_real_T;
#endif /* typedef_emxArray_real_T */

/* Variable Declarations */
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
void pcaRed(emxArray_real_T *data, emxArray_real_T *dataRed);

void pcaRed_api(const mxArray *prhs, const mxArray **plhs);

void pcaRed_atexit(void);

void pcaRed_initialize(void);

void pcaRed_terminate(void);

void pcaRed_xil_shutdown(void);

void pcaRed_xil_terminate(void);

#ifdef __cplusplus
}
#endif

#endif
/* End of code generation (_coder_pcaRed_api.h) */
