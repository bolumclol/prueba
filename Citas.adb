
with Ada.Integer_Text_IO,Ada.Text_IO,Ada.Numerics.Discrete_Random,Ada.Calendar;
USE Ada.Integer_Text_IO,Ada.Text_IO,Ada.Calendar;


procedure Main is

   subtype Espera is Integer range 1..5;
   package AzarBool is new Ada.Numerics.Discrete_Random(Boolean);
   package AzarEspera is new Ada.Numerics.Discrete_Random(Espera);

   use AzarBool;
   use AzarEspera;
   Generador : AzarBool.Generator;
   Generador2 : AzarEspera.Generator;


   MAX :constant := 20;
   ContadorClientes: Integer := 0;
   Abierto :Boolean := true;
   Tiempo_Cerrado : Duration :=5.0;



   function Contador return Integer is

   begin
      ContadorClientes := ContadorClientes+1;
      return ContadorClientes;
   end Contador;



   task type  Cliente  is
   end Cliente;
   type ClienteAcces is access Cliente;
   Clientes : array(1..MAX) of ClienteAcces;

   task Concesionario is
      entry Reparacion(A: in Integer);
      entry EntrarConcesionario(A: in Integer);
      entry CochesPrueba(A: in Integer);
      entry DevolverCoche(A: in Integer);


   end Concesionario;

   task Encargado is
      entry Pagar(A: in Integer);
      end Encargado;

   task EncargadoCerrar;


    procedure CrearClientes is
   begin
      for i in 1..MAX loop
      Clientes(i) := new Cliente;
      end loop;
      end CrearClientes;

   task body Concesionario is
      TiempoPrueba : Duration := 4.0;
      TiempoCompra : Duration := 2.0;
      CochesDisponibles : Integer := 5;

   begin
      CrearClientes;

      loop

         select
            when Abierto =>
         accept Reparacion(A: in Integer)  do
           Put_Line("Cliente" & A'Image & " Reparacion Completa");
            end Reparacion;
         or
               when Abierto =>
            accept EntrarConcesionario(A: in Integer)  do
               Put_Line("Cliente" & A'Image & " Entra al concesionario");
            end EntrarConcesionario;
         or

           when CochesDisponibles >0 and Abierto =>
            accept CochesPrueba(A: in Integer) do
                  Put_Line("Cliente" & A'Image & " Se le ha dejado el coche");
                  delay TiempoPrueba;
               CochesDisponibles :=CochesDisponibles-1;
            end CochesPrueba;
         or
               when Abierto =>
         accept DevolverCoche(A: in Integer)  do
            Put_Line("Cliente" & A'Image & " Se ha devuelto el coche");
            CochesDisponibles := CochesDisponibles+1;
         end DevolverCoche;

         end select;
      end loop;

   end Concesionario;

   task body Encargado is
   begin
      loop
          if Abierto then
         accept Pagar(A: in Integer) do
               Put_Line("Cliente" & A'Image & " Ha pagado");
            end Pagar;
         end if;

       end loop;


   end Encargado;

   task body EncargadoCerrar is
   begin
      loop
         delay Tiempo_Cerrado;
         if(Abierto) then
            Abierto := false;
            Put_Line("Encargado cierra el concesionario");
         else
            Abierto :=true;
            Put_Line("Encargado abre el concesionario");
         end if;
      end loop;
      end EncargadoCerrar;



   task body Cliente  is
      Reparar: AzarBool.Generator;
      ReparacionRapida : AzarBool.Generator;
      ComprarCoche : AzarBool.Generator;
      MaximoEspera : Integer:= 5;
      ContadorEspera : Integer :=0;
      NumeroCliente : Integer:=0;
      TiempoVuelve : Duration := 3.0;

   begin

      NumeroCliente := Contador;
      if  Random(Generador)  then
         Put_Line("Cliente" & NumeroCliente'Image & " solicita reparacion");
         if Random(Generador) then
            Concesionario.Reparacion(NumeroCliente);
            Encargado.Pagar(NumeroCliente);
         else
            for i in 1..Random(Generador2)   loop
               delay TiempoVuelve ;
               Put_Line("Cliente"& NumeroCliente'Image &  " pasa a ver si esta reparado el coche");
                if i = MaximoEspera then
                Put_Line("Cliente" & NumeroCliente'Image & " se queda esperando a la reparacion");
                end if;

               end loop;

            Concesionario.Reparacion(NumeroCliente);
            Encargado.Pagar(NumeroCliente);

         end if;
      else
         Concesionario.EntrarConcesionario(NumeroCliente);
         if Random(Generador) then
            Concesionario.CochesPrueba(NumeroCliente);
            Concesionario.DevolverCoche(NumeroCliente);
            Encargado.Pagar(NumeroCliente);
         else
            Put_Line("Cliente" & NumeroCliente'Image & " no le ha interesado ningun coche");
         end if;
      end if;

      Put_Line("Cliente" & NumeroCliente'Image & " se va");
   end Cliente;


begin

null;


end Main;
