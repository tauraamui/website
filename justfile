run:
    v run .

compile-blogs:
    v -d compile run .

run-watch:
    v -d vweb_livereload watch run .

install-deps:
    npm install -S hackcss-ext
    v install markdown
