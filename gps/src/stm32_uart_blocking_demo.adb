with STM32.Device;
with HAL;

with Uart;
with Screen_Draw;

procedure Stm32_Uart_Blocking_Demo is
   Rcv_Data    : HAL.UInt16;
begin
   Uart.Initialize;
   Screen_Draw.Display_Msg ("UART ready.");
   loop
      Uart.Get_Blocking (STM32.Device.USART_2, Data => Rcv_Data); 
      Screen_Draw.Display_Msg ("Received:" & Character'Val (Rcv_Data)'Image);
   end loop;
end Stm32_Uart_Blocking_Demo;
