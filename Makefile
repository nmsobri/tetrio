source = src
compiler = odin
executable = tetrio.exe
debug_dir = build/debug
release_dir = build/release


$(executable):$(release_dir) $(source)
	@$(compiler) build $(word 2, $^) -out:$(release_dir)/$(@)

$(release_dir):
	@mkdir -p build/release

$(debug_dir):
	@mkdir -p build/debug

run: $(executable)
	@$(release_dir)/$<

rerun: clean run

debug: clean $(debug_dir) $(source)
	@$(compiler) build $(word 3, $^) -debug -out:$(debug_dir)/$(executable)

release:clean $(release_dir) $(source)
	@$(compiler) build $(word 3, $^) -out:$(release_dir)/$(executable) -subsystem:windows -o:speed

clean:
	@rm -rf $(debug_dir)/*.exe $(debug_dir)/*.o $(debug_dir)/*.pdb; clear
	@rm -rf $(release_dir)/*.exe $(release_dir)/*.o $(release_dir)/*.pdb; clear