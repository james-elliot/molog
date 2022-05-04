--***********************************************************************--
--                                                                       --
--  PACKAGE SPECIFICATION: UNSIGNED                                      --
--  ----------------------                                               --
--                                                                       --
-- DATE    : 1-1-89                                                      --
-- AUTHOR  : B.KRINER                                                    --
-- VERSION : 0                                                           --
-- REVIEW  :                                                             --
--                                                                       --
--***********************************************************************--
WITH unsigned_operations;

PACKAGE unsigned IS

   TYPE unsigned_byte IS  RANGE - 128 .. 127;
   FOR unsigned_byte'SIZE USE 8;
   --  ALSYS compiler doesn't allow an unsigned representation
   --  (0 .. 255) on 8 bits.

   PACKAGE ubo IS NEW unsigned_operations (item => unsigned_byte);

   FUNCTION "NOT" (left : IN unsigned_byte) RETURN unsigned_byte RENAMES ubo.
         "NOT";
   FUNCTION "AND" (left, right : IN unsigned_byte) RETURN unsigned_byte
       RENAMES ubo."AND";
   FUNCTION "OR" (left, right : IN unsigned_byte) RETURN unsigned_byte
       RENAMES ubo."OR";
   FUNCTION "XOR" (left, right : IN unsigned_byte) RETURN unsigned_byte
       RENAMES ubo."XOR";
   -- ASL : Arithmetic Shift Left (decalage arithmetique a gauche)
   FUNCTION asl (arg : IN unsigned_byte;
                 num : IN natural) RETURN unsigned_byte RENAMES ubo.asl;
   -- ASR : Arithmetic Shift Right (decalage arithmetique a droite)
   FUNCTION asr (arg : IN unsigned_byte;
                 num : IN natural) RETURN unsigned_byte RENAMES ubo.asr;



   TYPE unsigned_word IS  RANGE - 32768 .. 32767;
   FOR unsigned_word'SIZE USE 16;
   --  ALSYS compiler doesn't allow an unsigned representation
   --  (0 .. 65535) on 16 bits.

   PACKAGE uwo IS NEW unsigned_operations (item => unsigned_word);

   FUNCTION "NOT" (left : IN unsigned_word) RETURN unsigned_word RENAMES uwo.
         "NOT";
   FUNCTION "AND" (left, right : IN unsigned_word) RETURN unsigned_word
       RENAMES uwo."AND";
   FUNCTION "OR" (left, right : IN unsigned_word) RETURN unsigned_word
       RENAMES uwo."OR";
   FUNCTION "XOR" (left, right : IN unsigned_word) RETURN unsigned_word
       RENAMES uwo."XOR";
   -- ASL : Arithmetic Shift Left (decalage arithmetique a gauche)
   FUNCTION asl (arg : IN unsigned_word;
                 num : IN natural) RETURN unsigned_word RENAMES uwo.asl;
   -- ASR : Arithmetic Shift Right (decalage arithmetique a droite)
   FUNCTION asr (arg : IN unsigned_word;
                 num : IN natural) RETURN unsigned_word RENAMES uwo.asr;



   TYPE unsigned_longword IS  RANGE - (2 ** 31) .. (2 ** 31) - 1;
   FOR unsigned_longword'SIZE USE 32;

   PACKAGE ulo IS NEW unsigned_operations (item => unsigned_longword);

   FUNCTION "NOT" (left : IN unsigned_longword) RETURN unsigned_longword
       RENAMES ulo."NOT";
   FUNCTION "AND"
       (left, right : IN unsigned_longword) RETURN unsigned_longword RENAMES
      ulo."AND";
   FUNCTION "OR" (left, right : IN unsigned_longword) RETURN unsigned_longword
       RENAMES ulo."OR";
   FUNCTION "XOR"
       (left, right : IN unsigned_longword) RETURN unsigned_longword RENAMES
      ulo."XOR";
   -- ASL : Arithmetic Shift Left (decalage arithmetique a gauche)
   FUNCTION asl (arg : IN unsigned_longword;
                 num : IN natural) RETURN unsigned_longword RENAMES ulo.asl;
   -- ASR : Arithmetic Shift Right (decalage arithmetique a droite)
   FUNCTION asr (arg : IN unsigned_longword;
                 num : IN natural) RETURN unsigned_longword RENAMES ulo.asr;

END unsigned;

