#!/bin/sh -exu

rm -rf ocamlfind
cp -r src ocamlfind

cd ocamlfind/external_lib

ocamlfind ocamlopt -a -o libA.cmxa libA.ml
ocamlfind ocamlopt -a -o libB.cmxa -I . libB.ml

cd ../

mkdir ocamlpath
mkdir ocamlpath/libA
mkdir ocamlpath/libB

cp external_lib/libA.* ocamlpath/libA
cp external_lib/META.libA ocamlpath/libA/META

cp external_lib/libB.* ocamlpath/libB
cp external_lib/META.libB ocamlpath/libB/META

export OCAMLPATH=$(realpath ocamlpath)

cd local_lib

ocamlfind ocamlopt -a -o A.cmxa A.ml -package libB
ocamlfind ocamlopt -a -o B.cmxa -I . B.ml -package libB
ocamlfind ocamlopt -o exec.exe -I . -package libB -linkpkg A.cmxa B.cmxa exec.ml
./exec.exe
