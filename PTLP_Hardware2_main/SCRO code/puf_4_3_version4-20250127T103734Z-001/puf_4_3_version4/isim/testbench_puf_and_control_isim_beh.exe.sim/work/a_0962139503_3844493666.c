/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

/* This file is designed for use with ISim build 0x7708f090 */

#define XSI_HIDE_SYMBOL_SPEC true
#include "xsi.h"
#include <memory.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
static const char *ng0 = "E:/new codes/SCRO_DCU_(4_3)/puf_4_3_version2/Decoder_D.vhd";
extern char *IEEE_P_1242562249;

int ieee_p_1242562249_sub_1657552908_1035706684(char *, char *, char *);


static void work_a_0962139503_3844493666_p_0(char *t0)
{
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    char *t6;
    char *t7;
    unsigned char t8;
    int t9;
    int t10;
    unsigned int t11;
    unsigned int t12;
    unsigned int t13;
    char *t14;

LAB0:    xsi_set_current_line(19, ng0);
    t1 = xsi_get_transient_memory(64U);
    memset(t1, 0, 64U);
    t2 = t1;
    memset(t2, (unsigned char)2, 64U);
    t3 = (t0 + 3072);
    t4 = (t3 + 56U);
    t5 = *((char **)t4);
    t6 = (t5 + 56U);
    t7 = *((char **)t6);
    memcpy(t7, t1, 64U);
    xsi_driver_first_trans_fast_port(t3);
    xsi_set_current_line(21, ng0);
    t1 = (t0 + 1032U);
    t2 = *((char **)t1);
    t8 = *((unsigned char *)t2);
    t1 = (t0 + 1192U);
    t3 = *((char **)t1);
    t1 = (t0 + 4788U);
    t9 = ieee_p_1242562249_sub_1657552908_1035706684(IEEE_P_1242562249, t3, t1);
    t10 = (t9 - 63);
    t11 = (t10 * -1);
    t12 = (1 * t11);
    t13 = (0U + t12);
    t4 = (t0 + 3072);
    t5 = (t4 + 56U);
    t6 = *((char **)t5);
    t7 = (t6 + 56U);
    t14 = *((char **)t7);
    *((unsigned char *)t14) = t8;
    xsi_driver_first_trans_delta(t4, t13, 1, 0LL);
    xsi_set_current_line(23, ng0);
    t1 = (t0 + 1032U);
    t2 = *((char **)t1);
    t8 = *((unsigned char *)t2);
    t1 = (t0 + 1352U);
    t3 = *((char **)t1);
    t1 = (t0 + 4804U);
    t9 = ieee_p_1242562249_sub_1657552908_1035706684(IEEE_P_1242562249, t3, t1);
    t10 = (t9 - 63);
    t11 = (t10 * -1);
    t12 = (1 * t11);
    t13 = (0U + t12);
    t4 = (t0 + 3072);
    t5 = (t4 + 56U);
    t6 = *((char **)t5);
    t7 = (t6 + 56U);
    t14 = *((char **)t7);
    *((unsigned char *)t14) = t8;
    xsi_driver_first_trans_delta(t4, t13, 1, 0LL);
    t1 = (t0 + 2992);
    *((int *)t1) = 1;

LAB1:    return;
}


extern void work_a_0962139503_3844493666_init()
{
	static char *pe[] = {(void *)work_a_0962139503_3844493666_p_0};
	xsi_register_didat("work_a_0962139503_3844493666", "isim/testbench_puf_and_control_isim_beh.exe.sim/work/a_0962139503_3844493666.didat");
	xsi_register_executes(pe);
}
