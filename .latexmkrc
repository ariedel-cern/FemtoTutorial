# Run `latexmk` from the project root.
@default_files = ('slides/main.tex');
$pdf_mode = 1;
$out_dir = 'slides';
$aux_dir = '.cache/beamer';
$emulate_aux = 1;
$pdflatex = 'pdflatex -interaction=nonstopmode -halt-on-error -file-line-error %O %S';

# Keep TeX temporary files inside the project cache as well.
use File::Path qw(make_path);
use Cwd qw(abs_path);
make_path('.cache/beamer');
$ENV{'TMPDIR'} = abs_path('.cache');
