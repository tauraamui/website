run:
    v run ./src

deploy: compile-blogs compile transfer-to-server

compile:
    v ./src -o website.bin -prod

compile-blogs:
    v run compile_blogs.v

transfer-to-server:
    scp -r ./blog/ tauraamui@tauraamui.website:~/
    scp ./website.bin tauraamui@tauraamui.website:~/

run-watch:
    v -d vweb_livereload watch run .

install-deps:
    pnpm install -S hackcss-ext
    v install markdown
