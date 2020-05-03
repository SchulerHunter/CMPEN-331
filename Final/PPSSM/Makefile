.PHONY: clean test testmore

test: *.py
	@chmod +x PPSSM.py
	@echo About to run PPSSM on input image \"ex1\" with instruction count limit 75 and cycle limit 150
	./PPSSM.py ex1 75 150

testmore: *.py
	@chmod +x PPSSM.py
	@echo About to run PPSSM on input image \"ex2\" with instruction count limit 4096 and cycle limit 8192
	./PPSSM.py ex2 4096 8192 | tee ex2.test.out
	@diff ex2.out ex2.test.out | tee ex2.diff


clean:
	@echo Deleting python3 PYC cache, if present
	-@rm -rf __pycache__
