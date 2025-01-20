/*
 * xzsvdc.c
 *
 * Code generation for function 'xzsvdc'
 *
 */

/* Include files */
#include "xzsvdc.h"
#include "pcaRed_emxutil.h"
#include "pcaRed_types.h"
#include "rt_nonfinite.h"
#include "xaxpy.h"
#include "xdotc.h"
#include "xnrm2.h"
#include "xrot.h"
#include "xrotg.h"
#include "xswap.h"
#include <math.h>
#include <string.h>

/* Function Definitions */
int xzsvdc(emxArray_real_T *A, emxArray_real_T *U, double S_data[],
           double V_data[], int V_size[2])
{
  emxArray_real_T *work;
  emxArray_real_T *x;
  double e_data[12];
  double s_data[12];
  double nrm;
  double rt;
  double sm;
  double *A_data;
  double *U_data;
  double *work_data;
  double *x_data;
  int S_size;
  int i;
  int ii;
  int jj;
  int n;
  int ns;
  int p;
  int q;
  int qjj;
  A_data = A->data;
  n = A->size[0];
  p = A->size[1];
  if (A->size[0] + 1 <= A->size[1]) {
    ns = A->size[0];
  } else {
    ns = A->size[1] - 1;
  }
  qjj = A->size[0];
  S_size = A->size[1];
  if (qjj <= S_size) {
    S_size = qjj;
  }
  if (ns >= 0) {
    memset(&s_data[0], 0, (unsigned int)(ns + 1) * sizeof(double));
  }
  ns = A->size[1];
  if (ns - 1 >= 0) {
    memset(&e_data[0], 0, (unsigned int)ns * sizeof(double));
  }
  emxInit_real_T(&work, 1);
  i = work->size[0];
  work->size[0] = A->size[0];
  emxEnsureCapacity_real_T(work, i);
  work_data = work->data;
  ns = A->size[0];
  for (i = 0; i < ns; i++) {
    work_data[i] = 0.0;
  }
  i = U->size[0] * U->size[1];
  U->size[0] = A->size[0];
  U->size[1] = S_size;
  emxEnsureCapacity_real_T(U, i);
  U_data = U->data;
  ns = A->size[0] * S_size;
  for (i = 0; i < ns; i++) {
    U_data[i] = 0.0;
  }
  emxInit_real_T(&x, 2);
  i = x->size[0] * x->size[1];
  x->size[0] = A->size[1];
  x->size[1] = A->size[1];
  emxEnsureCapacity_real_T(x, i);
  x_data = x->data;
  ns = A->size[1] * A->size[1];
  for (i = 0; i < ns; i++) {
    x_data[i] = 0.0;
  }
  if ((A->size[0] == 0) || (A->size[1] == 0)) {
    qjj = A->size[0];
    if (qjj > S_size) {
      qjj = S_size;
    }
    for (ii = 0; ii < qjj; ii++) {
      U_data[ii + U->size[0] * ii] = 1.0;
    }
    i = A->size[1];
    for (ii = 0; ii < i; ii++) {
      x_data[ii + x->size[0] * ii] = 1.0;
    }
  } else {
    double snorm;
    int m;
    int nct;
    int nctp1;
    int nmq;
    int nrt;
    int qp1;
    int qq;
    if (A->size[1] >= 2) {
      qjj = A->size[1] - 2;
    } else {
      qjj = 0;
    }
    nrt = A->size[0];
    if (qjj <= nrt) {
      nrt = qjj;
    }
    qjj = A->size[0] - 1;
    nct = A->size[1];
    if (qjj <= nct) {
      nct = qjj;
    }
    nctp1 = nct + 1;
    if (nct >= nrt) {
      i = nct;
    } else {
      i = nrt;
    }
    for (q = 0; q < i; q++) {
      boolean_T apply_transform;
      qp1 = q + 2;
      qq = (q + n * q) + 1;
      nmq = n - q;
      apply_transform = false;
      if (q + 1 <= nct) {
        nrm = xnrm2(nmq, A, qq);
        if (nrm > 0.0) {
          apply_transform = true;
          if (A_data[qq - 1] < 0.0) {
            nrm = -nrm;
          }
          s_data[q] = nrm;
          if (fabs(nrm) >= 1.0020841800044864E-292) {
            nrm = 1.0 / nrm;
            ns = (qq + nmq) - 1;
            for (qjj = qq; qjj <= ns; qjj++) {
              A_data[qjj - 1] *= nrm;
            }
          } else {
            ns = (qq + nmq) - 1;
            for (qjj = qq; qjj <= ns; qjj++) {
              A_data[qjj - 1] /= s_data[q];
            }
          }
          A_data[qq - 1]++;
          s_data[q] = -s_data[q];
        } else {
          s_data[q] = 0.0;
        }
      }
      for (jj = qp1; jj <= p; jj++) {
        qjj = q + n * (jj - 1);
        if (apply_transform) {
          xaxpy(nmq,
                -(xdotc(nmq, A, qq, A, qjj + 1) / A_data[q + A->size[0] * q]),
                qq, A, qjj + 1);
          A_data = A->data;
        }
        e_data[jj - 1] = A_data[qjj];
      }
      if (q + 1 <= nct) {
        for (ii = q + 1; ii <= n; ii++) {
          U_data[(ii + U->size[0] * q) - 1] = A_data[(ii + A->size[0] * q) - 1];
        }
      }
      if (q + 1 <= nrt) {
        qq = p - q;
        nrm = b_xnrm2(qq - 1, e_data, q + 2);
        if (nrm == 0.0) {
          e_data[q] = 0.0;
        } else {
          if (e_data[q + 1] < 0.0) {
            e_data[q] = -nrm;
          } else {
            e_data[q] = nrm;
          }
          nrm = e_data[q];
          if (fabs(e_data[q]) >= 1.0020841800044864E-292) {
            nrm = 1.0 / e_data[q];
            ns = q + qq;
            for (qjj = qp1; qjj <= ns; qjj++) {
              e_data[qjj - 1] *= nrm;
            }
          } else {
            ns = q + qq;
            for (qjj = qp1; qjj <= ns; qjj++) {
              e_data[qjj - 1] /= nrm;
            }
          }
          e_data[q + 1]++;
          e_data[q] = -e_data[q];
          if (q + 2 <= n) {
            for (ii = qp1; ii <= n; ii++) {
              work_data[ii - 1] = 0.0;
            }
            for (jj = qp1; jj <= p; jj++) {
              b_xaxpy(nmq - 1, e_data[jj - 1], A, (q + n * (jj - 1)) + 2, work,
                      q + 2);
              work_data = work->data;
            }
            for (jj = qp1; jj <= p; jj++) {
              b_xaxpy(nmq - 1, -e_data[jj - 1] / e_data[q + 1], work, q + 2, A,
                      (q + n * (jj - 1)) + 2);
              A_data = A->data;
            }
          }
        }
        for (ii = qp1; ii <= p; ii++) {
          x_data[(ii + x->size[0] * q) - 1] = e_data[ii - 1];
        }
      }
    }
    if (A->size[1] <= A->size[0] + 1) {
      m = A->size[1] - 1;
    } else {
      m = A->size[0];
    }
    if (nct < A->size[1]) {
      s_data[nct] = A_data[nct + A->size[0] * nct];
    }
    if (A->size[0] < m + 1) {
      s_data[m] = 0.0;
    }
    if (nrt < m) {
      e_data[nrt] = A_data[nrt + A->size[0] * m];
    }
    e_data[m] = 0.0;
    if (nct + 1 <= S_size) {
      for (jj = nctp1; jj <= S_size; jj++) {
        for (ii = 0; ii < n; ii++) {
          U_data[ii + U->size[0] * (jj - 1)] = 0.0;
        }
        U_data[(jj + U->size[0] * (jj - 1)) - 1] = 1.0;
      }
    }
    for (q = nct; q >= 1; q--) {
      qp1 = q + 1;
      ns = n - q;
      qq = (q + n * (q - 1)) - 1;
      if (s_data[q - 1] != 0.0) {
        for (jj = qp1; jj <= S_size; jj++) {
          qjj = q + n * (jj - 1);
          xaxpy(ns + 1, -(xdotc(ns + 1, U, qq + 1, U, qjj) / U_data[qq]),
                qq + 1, U, qjj);
          U_data = U->data;
        }
        for (ii = q; ii <= n; ii++) {
          U_data[(ii + U->size[0] * (q - 1)) - 1] =
              -U_data[(ii + U->size[0] * (q - 1)) - 1];
        }
        U_data[qq]++;
        for (ii = 0; ii <= q - 2; ii++) {
          U_data[ii + U->size[0] * (q - 1)] = 0.0;
        }
      } else {
        for (ii = 0; ii < n; ii++) {
          U_data[ii + U->size[0] * (q - 1)] = 0.0;
        }
        U_data[qq] = 1.0;
      }
    }
    for (q = p; q >= 1; q--) {
      if ((q <= nrt) && (e_data[q - 1] != 0.0)) {
        qp1 = q + 1;
        qq = p - q;
        ns = (q + p * (q - 1)) + 1;
        for (jj = qp1; jj <= p; jj++) {
          qjj = (q + p * (jj - 1)) + 1;
          xaxpy(qq, -(xdotc(qq, x, ns, x, qjj) / x_data[ns - 1]), ns, x, qjj);
          x_data = x->data;
        }
      }
      for (ii = 0; ii < p; ii++) {
        x_data[ii + x->size[0] * (q - 1)] = 0.0;
      }
      x_data[(q + x->size[0] * (q - 1)) - 1] = 1.0;
    }
    nmq = m;
    qq = 0;
    snorm = 0.0;
    for (q = 0; q <= m; q++) {
      nrm = s_data[q];
      if (nrm != 0.0) {
        rt = fabs(nrm);
        nrm /= rt;
        s_data[q] = rt;
        if (q < m) {
          e_data[q] /= nrm;
        }
        if (q + 1 <= n) {
          ns = n * q;
          i = ns + n;
          for (qjj = ns + 1; qjj <= i; qjj++) {
            U_data[qjj - 1] *= nrm;
          }
        }
      }
      if (q < m) {
        nrm = e_data[q];
        if (nrm != 0.0) {
          rt = fabs(nrm);
          nrm = rt / nrm;
          e_data[q] = rt;
          s_data[q + 1] *= nrm;
          ns = p * (q + 1);
          i = ns + p;
          for (qjj = ns + 1; qjj <= i; qjj++) {
            x_data[qjj - 1] *= nrm;
          }
        }
      }
      snorm = fmax(snorm, fmax(fabs(s_data[q]), fabs(e_data[q])));
    }
    while ((m + 1 > 0) && (qq < 75)) {
      boolean_T exitg1;
      ii = m;
      exitg1 = false;
      while (!(exitg1 || (ii == 0))) {
        nrm = fabs(e_data[ii - 1]);
        if ((nrm <= 2.2204460492503131E-16 *
                        (fabs(s_data[ii - 1]) + fabs(s_data[ii]))) ||
            (nrm <= 1.0020841800044864E-292) ||
            ((qq > 20) && (nrm <= 2.2204460492503131E-16 * snorm))) {
          e_data[ii - 1] = 0.0;
          exitg1 = true;
        } else {
          ii--;
        }
      }
      if (ii == m) {
        ns = 4;
      } else {
        qjj = m + 1;
        ns = m + 1;
        exitg1 = false;
        while ((!exitg1) && (ns >= ii)) {
          qjj = ns;
          if (ns == ii) {
            exitg1 = true;
          } else {
            nrm = 0.0;
            if (ns < m + 1) {
              nrm = fabs(e_data[ns - 1]);
            }
            if (ns > ii + 1) {
              nrm += fabs(e_data[ns - 2]);
            }
            rt = fabs(s_data[ns - 1]);
            if ((rt <= 2.2204460492503131E-16 * nrm) ||
                (rt <= 1.0020841800044864E-292)) {
              s_data[ns - 1] = 0.0;
              exitg1 = true;
            } else {
              ns--;
            }
          }
        }
        if (qjj == ii) {
          ns = 3;
        } else if (qjj == m + 1) {
          ns = 1;
        } else {
          ns = 2;
          ii = qjj;
        }
      }
      switch (ns) {
      case 1: {
        rt = e_data[m - 1];
        e_data[m - 1] = 0.0;
        for (qjj = m; qjj >= ii + 1; qjj--) {
          double sqds;
          sqds = xrotg(&s_data[qjj - 1], &rt, &sm);
          if (qjj > ii + 1) {
            double b;
            b = e_data[qjj - 2];
            rt = -sm * b;
            e_data[qjj - 2] = b * sqds;
          }
          xrot(p, x, p * (qjj - 1) + 1, p * m + 1, sqds, sm);
          x_data = x->data;
        }
      } break;
      case 2: {
        rt = e_data[ii - 1];
        e_data[ii - 1] = 0.0;
        for (qjj = ii + 1; qjj <= m + 1; qjj++) {
          double b;
          double sqds;
          sqds = xrotg(&s_data[qjj - 1], &rt, &sm);
          b = e_data[qjj - 1];
          rt = -sm * b;
          e_data[qjj - 1] = b * sqds;
          xrot(n, U, n * (qjj - 1) + 1, n * (ii - 1) + 1, sqds, sm);
        }
      } break;
      case 3: {
        double b;
        double scale;
        double sqds;
        nrm = s_data[m - 1];
        rt = e_data[m - 1];
        scale = fmax(fmax(fmax(fmax(fabs(s_data[m]), fabs(nrm)), fabs(rt)),
                          fabs(s_data[ii])),
                     fabs(e_data[ii]));
        sm = s_data[m] / scale;
        nrm /= scale;
        rt /= scale;
        sqds = s_data[ii] / scale;
        b = ((nrm + sm) * (nrm - sm) + rt * rt) / 2.0;
        nrm = sm * rt;
        nrm *= nrm;
        if ((b != 0.0) || (nrm != 0.0)) {
          rt = sqrt(b * b + nrm);
          if (b < 0.0) {
            rt = -rt;
          }
          rt = nrm / (b + rt);
        } else {
          rt = 0.0;
        }
        rt += (sqds + sm) * (sqds - sm);
        nrm = sqds * (e_data[ii] / scale);
        for (qjj = ii + 1; qjj <= m; qjj++) {
          sqds = xrotg(&rt, &nrm, &sm);
          if (qjj > ii + 1) {
            e_data[qjj - 2] = rt;
          }
          nrm = e_data[qjj - 1];
          b = s_data[qjj - 1];
          e_data[qjj - 1] = sqds * nrm - sm * b;
          rt = sm * s_data[qjj];
          s_data[qjj] *= sqds;
          xrot(p, x, p * (qjj - 1) + 1, p * qjj + 1, sqds, sm);
          x_data = x->data;
          s_data[qjj - 1] = sqds * b + sm * nrm;
          sqds = xrotg(&s_data[qjj - 1], &rt, &sm);
          b = e_data[qjj - 1];
          rt = sqds * b + sm * s_data[qjj];
          s_data[qjj] = -sm * b + sqds * s_data[qjj];
          nrm = sm * e_data[qjj];
          e_data[qjj] *= sqds;
          if (qjj < n) {
            xrot(n, U, n * (qjj - 1) + 1, n * qjj + 1, sqds, sm);
          }
        }
        e_data[m - 1] = rt;
        qq++;
      } break;
      default:
        if (s_data[ii] < 0.0) {
          s_data[ii] = -s_data[ii];
          ns = p * ii;
          i = ns + p;
          for (qjj = ns + 1; qjj <= i; qjj++) {
            x_data[qjj - 1] = -x_data[qjj - 1];
          }
        }
        qp1 = ii + 1;
        while ((ii + 1 < nmq + 1) && (s_data[ii] < s_data[qp1])) {
          rt = s_data[ii];
          s_data[ii] = s_data[qp1];
          s_data[qp1] = rt;
          if (ii + 1 < p) {
            xswap(p, x, p * ii + 1, p * (ii + 1) + 1);
            x_data = x->data;
          }
          if (ii + 1 < n) {
            xswap(n, U, n * ii + 1, n * (ii + 1) + 1);
          }
          ii = qp1;
          qp1++;
        }
        qq = 0;
        m--;
        break;
      }
    }
  }
  emxFree_real_T(&work);
  V_size[0] = A->size[1];
  V_size[1] = S_size;
  for (qjj = 0; qjj < S_size; qjj++) {
    S_data[qjj] = s_data[qjj];
    for (ns = 0; ns < p; ns++) {
      V_data[ns + V_size[0] * qjj] = x_data[ns + x->size[0] * qjj];
    }
  }
  emxFree_real_T(&x);
  return S_size;
}

/* End of code generation (xzsvdc.c) */
