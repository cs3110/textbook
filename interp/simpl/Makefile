default:
	ocamlbuild -use-ocamlfind main.byte
	utop

test:
	ocamlbuild -use-ocamlfind test.byte && ./test.byte

clean:
	ocamlbuild -clean
