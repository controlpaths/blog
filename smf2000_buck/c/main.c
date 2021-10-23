
/*******************************************************************************

Author: P.Trujillo (pablo@controlpaths.com)
Description: Main code for Buck control.

*******************************************************************************/
#include "platform.h"
#include "core_pwm.h"
#include "hw_reg_access.h"

#define DELAY_COUNT     100
#define PWM_PRESCALE    20
#define PWM_PERIOD      200

pwm_instance_t the_pwm;

void delay( void );

int main( void ) {
    uint32_t duty_cycle = 10;

    uint32_t input_current_int;
    uint32_t input_voltage_int;
    uint32_t output_current_int;
    uint32_t output_voltage_int;

    int32_t error_int = 0;
    int32_t reference_int = 180;

    int32_t gain_p = 5;
    float gain_i = 0.01;

    int32_t proportional;
    int32_t integral;
    float error_i;
    int32_t accumulator = 0;


    /* pwm initialization */
    PWM_init( &the_pwm, COREPWM_BASE_ADDR, PWM_PRESCALE, PWM_PERIOD ) ;
    PWM_set_duty_cycle( &the_pwm, PWM_1, duty_cycle );

    while ( 1 )
    {

        delay();


        input_current_int = HW_get_8bit_reg(0x50001000);
        input_voltage_int = HW_get_8bit_reg(0x50001004);
        output_current_int = HW_get_8bit_reg(0x50001008);
        output_voltage_int = HW_get_8bit_reg(0x5000100c);

        /* compute error */
        error_int = reference_int - output_voltage_int;

        /* proportional gain */
        proportional = error_int * gain_p;

        /* integral gain */
        error_i = error_int * gain_i;
        integral = integral + error_i;

        /* Addition of both gains */
        duty_cycle = proportional + integral;

        /* apply saturation */
        if (duty_cycle > 200)
           duty_cycle = 200;

        if (duty_cycle < 0)
          duty_cycle = 0;

        /* write duty cycle */
        PWM_set_duty_cycle( &the_pwm, PWM_1, duty_cycle );
    }
}

void delay( void )
{
    volatile int counter = 0;

    while ( counter < DELAY_COUNT )
    {
        counter++;
    }
}
