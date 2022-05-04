GENERIC

   TYPE item IS RANGE <>; -- Unsigned type.
   WITH FUNCTION "-" (left : IN item) RETURN item IS <>;
   WITH FUNCTION "-" (left, right : IN item) RETURN item IS <>;
   WITH FUNCTION "+" (left, right : IN item) RETURN item IS <>;
   WITH FUNCTION "*" (left, right : IN item) RETURN item IS <>;
   WITH FUNCTION "/" (left, right : IN item) RETURN item IS <>;
   WITH FUNCTION "MOD" (left, right : IN item) RETURN item IS <>;
   WITH FUNCTION "<" (left, right : IN item) RETURN boolean IS <>;

PACKAGE unsigned_operations IS

   FUNCTION "NOT" (left : IN item) RETURN item;
   FUNCTION "AND" (left, right : IN item) RETURN item;
   FUNCTION "OR" (left, right : IN item) RETURN item;
   FUNCTION "XOR" (left, right : IN item) RETURN item;
   FUNCTION asl (arg : IN item;
                 num : IN natural) RETURN item;
   FUNCTION asr (arg : IN item;
                 num : IN natural) RETURN item;

END unsigned_operations;

