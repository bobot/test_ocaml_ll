#!/bin/sh -exu

rm -rf ocaml_ll
cp -r src ocaml_ll

cd ocaml_ll/external_lib

ocamlopt -a -o libA.cmxa libA.ml
ocamlopt -c -o libB.cmx -I . libB.ml
ocamlopt -noautoliblink -a -o libB.cmxa libB.cmx -require liba

# libA is not an acceptable library name but it is an acceptable module name

cd ../

mkdir ocamlpath
mkdir ocamlpath/liba
mkdir ocamlpath/libb

cp external_lib/libA.* ocamlpath/liba
mv ocamlpath/liba/libA.cmxa ocamlpath/liba/lib.cmxa
mv ocamlpath/liba/libA.a ocamlpath/liba/lib.a

cp external_lib/libB.* ocamlpath/libb
mv ocamlpath/libb/libB.cmxa ocamlpath/libb/lib.cmxa
mv ocamlpath/libb/libB.a ocamlpath/libb/lib.a

export OCAMLPATH=$(realpath ocamlpath)

cd local_lib

ocamlopt -a -o A.cmxa A.ml -require libb
ocamlopt -c -o B.cmx -I . B.ml -require libb
ocamlopt -noautoliblink -a -o B.cmxa -I . B.cmx -require a -require libb

# Using the cmxa without -noautoliblink doesn't work because the library a is not in OCAMLPATH
ocamlopt -o exec.exe -I . A.cmxa B.cmxa exec.ml || echo FAIL
ocamlopt -o exec.exe -I . B.cmxa exec.ml || echo FAIL

#It works Without -noautoliblink but by extending ocamlpath
mkdir -p local_ocamlpath/a/
cp A.* local_ocamlpath/a/
mv local_ocamlpath/a/A.cmxa local_ocamlpath/a/lib.cmxa
mv local_ocamlpath/a/A.a local_ocamlpath/a/lib.a
mkdir local_ocamlpath/b/
cp B.* local_ocamlpath/b/
mv local_ocamlpath/b/B.cmxa local_ocamlpath/b/lib.cmxa
mv local_ocamlpath/b/B.a local_ocamlpath/b/lib.a

OCAMLPATH=$(realpath local_ocamlpath):$OCAMLPATH ocamlopt -o exec.exe -I . -require a -require b exec.ml
./exec.exe
rm exec.exe

# It works by doing the lookup manually
ocamlopt -c -o exec.cmx -I . -require libb exec.ml
ocamlopt -noautoliblink -o exec.exe -I . $OCAMLPATH/liba/lib.cmxa $OCAMLPATH/libb/lib.cmxa A.cmxa B.cmxa exec.cmx
./exec.exe

# We currently can't add the -require for dynlink even with -noautoliblink
ocamlopt -noautoliblink -o exec.exe -I . $OCAMLPATH/liba/lib.cmxa $OCAMLPATH/libb/lib.cmxa A.cmxa B.cmxa exec.cmx -require a -require b -require liba -require libb
