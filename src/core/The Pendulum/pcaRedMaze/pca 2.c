/*
 * pca.c
 *
 * Code generation for function 'pca'
 *
 */

/* Include files */
#include "pca.h"
#include "pcaRed_emxutil.h"
#include "pcaRed_types.h"
#include "rt_nonfinite.h"
#include "xzsvdc.h"
#include "rt_nonfinite.h"
#include <math.h>
#include <string.h>

/* Function Declarations */
static int localSVD(const emxArray_real_T *x, int DOF, double coeffOut_data[],
                    int coeffOut_size[2], emxArray_real_T *scoreOut,
                    double latentOut_data[], emxArray_real_T *tsquared,
                    double explained_data[], int *explained_size);

static void localTSquared(const emxArray_real_T *score,
                          const double latent_data[], int latent_size, int DOF,
                          int p, emxArray_real_T *tsquared);

static void wnanmean(const emxArray_real_T *X, boolean_T noNaNs,
                     double M_data[], int M_size[2]);

/* Function Definitions */
static int localSVD(const emxArray_real_T *x, int DOF, double coeffOut_data[],
                    int coeffOut_size[2], emxArray_real_T *scoreOut,
                    double latentOut_data[], emxArray_real_T *tsquared,
                    double explained_data[], int *explained_size)
{
  emxArray_real_T *b_x;
  emxArray_real_T *score;
  double coeff_data[144];
  double latent_data[12];
  const double *x_data;
  double y;
  double *scoreOut_data;
  double *score_data;
  int coeff_size[2];
  int i;
  int j;
  int latentOut_size;
  int ncols;
  int nrows;
  int nsv;
  x_data = x->data;
  nrows = x->size[0] - 1;
  ncols = x->size[1];
  emxInit_real_T(&b_x, 2);
  j = b_x->size[0] * b_x->size[1];
  b_x->size[0] = x->size[0];
  b_x->size[1] = x->size[1];
  emxEnsureCapacity_real_T(b_x, j);
  score_data = b_x->data;
  nsv = x->size[0] * x->size[1] - 1;
  for (j = 0; j <= nsv; j++) {
    score_data[j] = x_data[j];
  }
  emxInit_real_T(&score, 2);
  latentOut_size = xzsvdc(b_x, score, latent_data, coeff_data, coeff_size);
  score_data = score->data;
  emxFree_real_T(&b_x);
  nsv = score->size[1] - 1;
  for (j = 0; j <= nsv; j++) {
    for (i = 0; i <= nrows; i++) {
      score_data[i + score->size[0] * j] *= latent_data[j];
    }
  }
  for (j = 0; j <= nsv; j++) {
    y = latent_data[j];
    y = y * y / (double)DOF;
    latent_data[j] = y;
  }
  localTSquared(score, latent_data, latentOut_size, DOF, x->size[1], tsquared);
  if (DOF < x->size[1]) {
    latentOut_size = score->size[1];
    if (DOF <= latentOut_size) {
      latentOut_size = DOF;
    }
    j = scoreOut->size[0] * scoreOut->size[1];
    scoreOut->size[0] = x->size[0];
    scoreOut->size[1] = latentOut_size;
    emxEnsureCapacity_real_T(scoreOut, j);
    scoreOut_data = scoreOut->data;
    for (j = 0; j < latentOut_size; j++) {
      for (i = 0; i <= nrows; i++) {
        scoreOut_data[i + scoreOut->size[0] * j] =
            score_data[i + score->size[0] * j];
      }
    }
    if (latentOut_size - 1 >= 0) {
      memcpy(&latentOut_data[0], &latent_data[0],
             (unsigned int)latentOut_size * sizeof(double));
    }
    coeffOut_size[0] = x->size[1];
    coeffOut_size[1] = latentOut_size;
    for (j = 0; j < latentOut_size; j++) {
      for (i = 0; i < ncols; i++) {
        coeffOut_data[i + coeffOut_size[0] * j] =
            coeff_data[i + coeff_size[0] * j];
      }
    }
  } else {
    j = scoreOut->size[0] * scoreOut->size[1];
    scoreOut->size[0] = score->size[0];
    scoreOut->size[1] = score->size[1];
    emxEnsureCapacity_real_T(scoreOut, j);
    scoreOut_data = scoreOut->data;
    nsv = score->size[0] * score->size[1];
    for (j = 0; j < nsv; j++) {
      scoreOut_data[j] = score_data[j];
    }
    if (latentOut_size - 1 >= 0) {
      memcpy(&latentOut_data[0], &latent_data[0],
             (unsigned int)latentOut_size * sizeof(double));
    }
    coeffOut_size[0] = coeff_size[0];
    coeffOut_size[1] = coeff_size[1];
    nsv = coeff_size[0] * coeff_size[1];
    if (nsv - 1 >= 0) {
      memcpy(&coeffOut_data[0], &coeff_data[0],
             (unsigned int)nsv * sizeof(double));
    }
  }
  emxFree_real_T(&score);
  if (latentOut_size == 0) {
    y = 0.0;
  } else {
    y = latentOut_data[0];
    for (nsv = 2; nsv <= latentOut_size; nsv++) {
      y += latentOut_data[nsv - 1];
    }
  }
  *explained_size = latentOut_size;
  for (j = 0; j < latentOut_size; j++) {
    explained_data[j] = 100.0 * latentOut_data[j] / y;
  }
  return latentOut_size;
}

static void localTSquared(const emxArray_real_T *score,
                          const double latent_data[], int latent_size, int DOF,
                          int p, emxArray_real_T *tsquared)
{
  const double *score_data;
  double *tsquared_data;
  int exponent;
  int i;
  score_data = score->data;
  if ((score->size[0] == 0) || (score->size[1] == 0)) {
    i = tsquared->size[0] * tsquared->size[1];
    tsquared->size[0] = score->size[0];
    tsquared->size[1] = score->size[1];
    emxEnsureCapacity_real_T(tsquared, i);
    tsquared_data = tsquared->data;
    exponent = score->size[0] * score->size[1];
    for (i = 0; i < exponent; i++) {
      tsquared_data[i] = score_data[i];
    }
  } else {
    double absx;
    int m;
    int q;
    if (DOF > 1) {
      absx = fabs(latent_data[0]);
      if (rtIsInf(absx) || rtIsNaN(absx)) {
        absx = rtNaN;
      } else if (absx < 4.4501477170144028E-308) {
        absx = 4.94065645841247E-324;
      } else {
        frexp(absx, &exponent);
        absx = ldexp(1.0, exponent - 53);
      }
      if (DOF >= p) {
        exponent = DOF;
      } else {
        exponent = p;
      }
      absx *= (double)exponent;
      q = 0;
      for (exponent = 0; exponent < latent_size; exponent++) {
        if (latent_data[exponent] > absx) {
          q++;
        }
      }
    } else {
      q = 0;
    }
    m = score->size[0];
    i = tsquared->size[0] * tsquared->size[1];
    tsquared->size[0] = score->size[0];
    tsquared->size[1] = 1;
    emxEnsureCapacity_real_T(tsquared, i);
    tsquared_data = tsquared->data;
    exponent = score->size[0];
    for (i = 0; i < exponent; i++) {
      tsquared_data[i] = 0.0;
    }
    for (exponent = 0; exponent < q; exponent++) {
      absx = sqrt(latent_data[exponent]);
      for (i = 0; i < m; i++) {
        double d;
        d = score_data[i + score->size[0] * exponent] / absx;
        tsquared_data[i] += d * d;
      }
    }
  }
}

static void wnanmean(const emxArray_real_T *X, boolean_T noNaNs,
                     double M_data[], int M_size[2])
{
  const double *X_data;
  int i;
  int m;
  int n;
  int sz_idx_1;
  X_data = X->data;
  m = X->size[0] - 1;
  n = X->size[1] - 1;
  sz_idx_1 = X->size[1];
  M_size[0] = 1;
  M_size[1] = X->size[1];
  if (sz_idx_1 - 1 >= 0) {
    memset(&M_data[0], 0, (unsigned int)sz_idx_1 * sizeof(double));
  }
  if (!noNaNs) {
    for (sz_idx_1 = 0; sz_idx_1 <= n; sz_idx_1++) {
      double wcol;
      double xcol;
      wcol = 0.0;
      xcol = 0.0;
      for (i = 0; i <= m; i++) {
        double d;
        d = X_data[i + X->size[0] * sz_idx_1];
        if (!rtIsNaN(d)) {
          wcol++;
          xcol += d;
        }
      }
      M_data[sz_idx_1] = xcol / wcol;
    }
  } else {
    for (sz_idx_1 = 0; sz_idx_1 <= n; sz_idx_1++) {
      double wcol;
      double xcol;
      wcol = 0.0;
      xcol = 0.0;
      for (i = 0; i <= m; i++) {
        wcol++;
        xcol += X_data[i + X->size[0] * sz_idx_1];
      }
      M_data[sz_idx_1] = xcol / wcol;
    }
  }
}

void local_pca(emxArray_real_T *x, int NumComponents, double coeffOut_data[],
               int coeffOut_size[2], emxArray_real_T *scoreOut)
{
  emxArray_boolean_T *naninfo_isNaN;
  emxArray_int32_T *naninfo_nNaNsInRow;
  emxArray_real_T *score;
  emxArray_real_T *tsquared;
  emxArray_real_T *y;
  double coeff_data[144];
  double explained_data[12];
  double latent_data[12];
  double mu_data[12];
  double *x_data;
  double *y_data;
  int coeff_size[2];
  int mu_size[2];
  int DOF;
  int b_i;
  int b_n;
  int i;
  int i1;
  int irow;
  int j;
  int n;
  int naninfo_nRowsWithNaNs;
  int p;
  int *naninfo_nNaNsInRow_data;
  boolean_T noNaNs;
  boolean_T *naninfo_isNaN_data;
  x_data = x->data;
  n = x->size[0];
  i = x->size[1];
  b_n = x->size[0] - 1;
  p = x->size[1];
  DOF = 0;
  naninfo_nRowsWithNaNs = 0;
  emxInit_int32_T(&naninfo_nNaNsInRow);
  i1 = naninfo_nNaNsInRow->size[0];
  naninfo_nNaNsInRow->size[0] = x->size[0];
  emxEnsureCapacity_int32_T(naninfo_nNaNsInRow, i1);
  naninfo_nNaNsInRow_data = naninfo_nNaNsInRow->data;
  irow = x->size[0];
  for (i1 = 0; i1 < irow; i1++) {
    naninfo_nNaNsInRow_data[i1] = 0;
  }
  emxInit_boolean_T(&naninfo_isNaN);
  i1 = naninfo_isNaN->size[0] * naninfo_isNaN->size[1];
  naninfo_isNaN->size[0] = x->size[0];
  naninfo_isNaN->size[1] = x->size[1];
  emxEnsureCapacity_boolean_T(naninfo_isNaN, i1);
  naninfo_isNaN_data = naninfo_isNaN->data;
  irow = x->size[0] * x->size[1];
  for (i1 = 0; i1 < irow; i1++) {
    naninfo_isNaN_data[i1] = rtIsNaN(x_data[i1]);
  }
  for (j = 0; j < p; j++) {
    for (b_i = 0; b_i <= b_n; b_i++) {
      if (naninfo_isNaN_data[b_i + naninfo_isNaN->size[0] * j]) {
        naninfo_nNaNsInRow_data[b_i]++;
        DOF++;
      }
    }
  }
  emxFree_boolean_T(&naninfo_isNaN);
  for (b_i = 0; b_i <= b_n; b_i++) {
    if (naninfo_nNaNsInRow_data[b_i] > 0) {
      naninfo_nRowsWithNaNs++;
    }
  }
  noNaNs = (DOF <= 0);
  b_n = x->size[0] - naninfo_nRowsWithNaNs;
  DOF = b_n;
  if (b_n >= 1) {
    DOF = b_n - 1;
  }
  wnanmean(x, noNaNs, mu_data, mu_size);
  for (j = 0; j < i; j++) {
    for (b_i = 0; b_i < n; b_i++) {
      x_data[b_i + x->size[0] * j] -= mu_data[j];
    }
  }
  emxInit_real_T(&tsquared, 2);
  emxInit_real_T(&y, 2);
  if (noNaNs) {
    localSVD(x, DOF, coeff_data, coeff_size, y, latent_data, tsquared,
             explained_data, &b_n);
    y_data = y->data;
  } else {
    n = x->size[0];
    p = x->size[1];
    i = y->size[0] * y->size[1];
    y->size[0] = b_n;
    y->size[1] = x->size[1];
    emxEnsureCapacity_real_T(y, i);
    y_data = y->data;
    irow = -1;
    for (b_i = 0; b_i < n; b_i++) {
      if (naninfo_nNaNsInRow_data[b_i] == 0) {
        irow++;
        for (j = 0; j < p; j++) {
          y_data[irow + y->size[0] * j] = x_data[b_i + x->size[0] * j];
        }
      }
    }
    emxInit_real_T(&score, 2);
    localSVD(y, DOF, coeff_data, coeff_size, score, latent_data, tsquared,
             explained_data, &b_n);
    x_data = score->data;
    n = naninfo_nNaNsInRow->size[0];
    p = score->size[1] - 1;
    i = y->size[0] * y->size[1];
    y->size[0] = naninfo_nNaNsInRow->size[0];
    y->size[1] = score->size[1];
    emxEnsureCapacity_real_T(y, i);
    y_data = y->data;
    irow = -1;
    for (b_i = 0; b_i < n; b_i++) {
      if (naninfo_nNaNsInRow_data[b_i] > 0) {
        for (j = 0; j <= p; j++) {
          y_data[b_i + y->size[0] * j] = rtNaN;
        }
      } else {
        irow++;
        for (j = 0; j <= p; j++) {
          y_data[b_i + y->size[0] * j] = x_data[irow + score->size[0] * j];
        }
      }
    }
    emxFree_real_T(&score);
  }
  emxFree_real_T(&tsquared);
  emxFree_int32_T(&naninfo_nNaNsInRow);
  irow = coeff_size[0];
  b_n = y->size[0] - 1;
  if (NumComponents < DOF) {
    coeffOut_size[0] = coeff_size[0];
    coeffOut_size[1] = NumComponents;
    i = (unsigned char)NumComponents;
    for (j = 0; j < i; j++) {
      for (b_i = 0; b_i < irow; b_i++) {
        coeffOut_data[b_i + coeffOut_size[0] * j] =
            coeff_data[b_i + coeff_size[0] * j];
      }
    }
    i1 = scoreOut->size[0] * scoreOut->size[1];
    scoreOut->size[0] = y->size[0];
    scoreOut->size[1] = NumComponents;
    emxEnsureCapacity_real_T(scoreOut, i1);
    x_data = scoreOut->data;
    for (j = 0; j < i; j++) {
      for (b_i = 0; b_i <= b_n; b_i++) {
        x_data[b_i + scoreOut->size[0] * j] = y_data[b_i + y->size[0] * j];
      }
    }
  } else {
    coeffOut_size[0] = coeff_size[0];
    coeffOut_size[1] = coeff_size[1];
    irow = coeff_size[0] * coeff_size[1];
    if (irow - 1 >= 0) {
      memcpy(&coeffOut_data[0], &coeff_data[0],
             (unsigned int)irow * sizeof(double));
    }
    i = scoreOut->size[0] * scoreOut->size[1];
    scoreOut->size[0] = y->size[0];
    scoreOut->size[1] = y->size[1];
    emxEnsureCapacity_real_T(scoreOut, i);
    x_data = scoreOut->data;
    irow = y->size[0] * y->size[1];
    for (i = 0; i < irow; i++) {
      x_data[i] = y_data[i];
    }
  }
  emxFree_real_T(&y);
  irow = coeffOut_size[0] - 1;
  i = coeffOut_size[1];
  for (j = 0; j < i; j++) {
    double maxval;
    double sgn;
    maxval = 0.0;
    sgn = 1.0;
    for (b_i = 0; b_i <= irow; b_i++) {
      double absc;
      double d;
      d = coeffOut_data[b_i + coeffOut_size[0] * j];
      absc = fabs(d);
      if (absc > maxval) {
        maxval = absc;
        sgn = d;
        if (!rtIsNaN(d)) {
          if (d < 0.0) {
            sgn = -1.0;
          } else {
            sgn = (d > 0.0);
          }
        }
      }
    }
    if (sgn < 0.0) {
      for (b_i = 0; b_i <= irow; b_i++) {
        i1 = b_i + coeffOut_size[0] * j;
        coeffOut_data[i1] = -coeffOut_data[i1];
      }
      for (b_i = 0; b_i <= b_n; b_i++) {
        x_data[b_i + scoreOut->size[0] * j] =
            -x_data[b_i + scoreOut->size[0] * j];
      }
    }
  }
}

/* End of code generation (pca.c) */
