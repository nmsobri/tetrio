source = src
compiler = odin
executable = tetrio.exe

$(executable):$(source)
	@$(compiler) build $< -out:$(@)

run: $(executable)
	@./$<

rerun: clean run

debug: clean $(source)
	$(compiler) build $(word 2, $^) -debug -out:$(executable)

release:clean $(source)
	$(compiler) build $(word 2, $^) -out:$(executable) -subsystem:windows -o:speed

clean:
	@rm -rf *.o *.obj *.exe *.pdb; clear
