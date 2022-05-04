--***********************************************************************--
--                                                                       --
--  PACKAGE SPECIFICATION: C_TYPES                                       --
--  ----------------------                                               --
--                                                                       --
-- DATE    : 1-1-89                                                      --
-- AUTHOR  : D.FIGAROL                                                   --
-- VERSION : 0                                                           --
-- REVIEW  : B.KRINER,F.PREUX                                            --
--                                                                       --
--***********************************************************************--

WITH unsigned, system;

PACKAGE c_types IS


   TYPE int_type IS  RANGE - 32768 .. 32767;
   FOR int_type'SIZE USE 16;

   TYPE long_int_type IS  RANGE - 2 ** 31 .. (2 ** 31) - 1;
   FOR long_int_type'SIZE USE 32;

   SUBTYPE c_char IS character;

   SUBTYPE c_short IS int_type;

   SUBTYPE c_int IS long_int_type;

   SUBTYPE c_long IS long_int_type;

   SUBTYPE c_boolean IS long_int_type;
   c_false : c_boolean := 0;

   TYPE c_unsigned_char IS NEW unsigned.unsigned_byte;

   TYPE c_unsigned_short IS NEW unsigned.unsigned_word;

   TYPE c_unsigned_int IS NEW unsigned.unsigned_longword;

   TYPE c_unsigned_long IS NEW unsigned.unsigned_longword;

   TYPE c_pointer IS NEW system.address;
-- Non portable, et de toute facon non utilise.
--   c_null : CONSTANT c_pointer := c_pointer (system.no_addr);

END c_types;

