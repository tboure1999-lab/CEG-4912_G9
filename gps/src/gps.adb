with STM32.Device;
with HAL;

with Uart;
with Screen_Draw;

procedure Gps is

   type States_T is (Sentence_Type, Time_UTC, Latitude, Longitude, Invalid);
   State : States_T := Sentence_Type;
   Reset_Char : constant Character := '$';
   Split_Char : constant Character := ',';

   Buffer : String (1 .. 16) := (others => ' ');
   Current_Char : Character;
   Pos_In_buffer : Natural := 1;

   
   type Sentence_T is  (GNGGA, GNRMC, GNGSA, GNGSV, GNVTG, GNGLL);

   type Latitude_T is delta 10.0 ** (-3) digits 7;
   type Longitude_T is delta 10.0 ** (-3) digits 7;

   type Message_T is record
      Sentence : Sentence_T   := GNGGA;
      Time_UTC : Natural      := 1140;
      Latitude : Latitude_T   := 45.419;
      Longitude : Longitude_T := -75.657;
   end record;

   Message : Message_T;

   function Img (M : Message_T) return String is
   begin
      return M.Sentence'Image & " Time: " & M.Time_UTC'Image & " Latitude: " & M.Latitude'Image & " Longitude: " & M.Longitude'Image;
   end Img;

   function Update_State (Data : Character; Current_State : States_T) return States_T is
   begin
      if Data = Reset_Char then
         Screen_Draw.Display_Msg ("UpdtStateif1");
         return Sentence_Type;
      elsif Data = Split_Char then
         Screen_Draw.Display_Msg ("UpdtStateelsif1");
         case Current_State is
            when Sentence_Type =>
               if Sentence_T'Value (Buffer (1 .. Pos_In_buffer)) = GNGGA then
                  Message.Sentence := Sentence_T'Value (Buffer (1 .. Pos_In_buffer)); 
                  Pos_In_buffer := 1;
                  return Time_UTC;
               else
                  return Invalid;
               end if;
            when Time_UTC =>
               Message.Time_UTC := Natural'Value (Buffer (1 .. Pos_In_buffer));
               Pos_In_buffer := 1;
               return Latitude;
            when Latitude =>
               Message.Latitude := Latitude_T'Value (Buffer (1 .. Pos_In_buffer));
               Pos_In_buffer := 1;
               return Longitude;
            when Longitude =>
               Message.Longitude := Longitude_T'Value (Buffer (1 .. Pos_In_buffer));
               Pos_In_buffer := 1;
               Screen_Draw.Display_Msg (Img (Message));
               Message := (others => <>);
               return Invalid;
            when others => 
               Screen_Draw.Display_Msg ("Waiting for Data...");
               return Invalid;
         end case;
      else 
         Screen_Draw.Display_Msg (Img (Message));
         return Invalid;
      end if;
   end Update_State;
   Rcv_Data    : HAL.UInt16;

begin
   Uart.Initialize;
   loop
      Uart.Get_Blocking (STM32.Device.USART_2, Data => Rcv_Data);
      Current_Char := Character'Val (Rcv_Data);
      State := Update_State (Current_Char, State);
      Buffer (Pos_In_buffer) := Current_Char;
      if State /= Invalid then
         Pos_In_buffer := Pos_In_buffer + 1;
      end if;
   end loop;
end Gps;