alias la = ls -a
alias ll = ls -al

alias md = mkdir

alias mx = chmod +x
alias smx = sudo chmod +x
alias own = chown -R $"($env.USER):($env.USER)"
alias sown = sudo chown -R $"($env.USER):($env.USER)"

alias cs = clear

alias h = code --ozone-platform="wayland" --enable-features="WaylandWindowDecorations" .
alias H = code-insiders --ozone-platform="wayland" --enable-features="WaylandWindowDecorations" .
