using JSServe
using Observables
using WGLMakie
using Markdown

color = Observable("red")

x = collect(-π:0.01:π)
y = Observable(x)
n = Observable(1)

FUNCTIONS = ["sin", "cos", "tan", "exp", "identity"]

algorithm = Observable(first(FUNCTIONS))
dropdown_onchange = js"JSServe.update_obs($algorithm, this.options[this.selectedIndex].text);"
dropdown = DOM.select(DOM.option.(FUNCTIONS); onchange=dropdown_onchange)

color_css = map(x-> "color: $(x)", color)

app = App() do
    button = JSServe.Button("click me")
    button_draw = JSServe.Button("draw")

    slider = JSServe.Slider(1:10)
    
    on(button) do _
        color[] = rand(["red", "green", "blue"])
        y[] = rand(map(f -> f.(x), [Meta.parse(f) |> eval for f in FUNCTIONS]))
    end

    on(button_draw) do _
        y[] = eval(Meta.parse(algorithm.val)).(x)
    end

    on(slider) do v
        n[] = v
        y[] = x .^ v
    end
        

    # document
    document = md"""
    # Web Application using JuliaLang/JSServe.jl
    
    - [JuliaLang](https://julialang.org/)
    - [JSServe.jl](https://github.com/SimonDanisch/JSServe.jl)
    - x^$(n) $(slider)
    - $(dropdown) $(button_draw)
    """
    
    # Draw function graph
    scene = Scene()
    lines!(scene, x, y)
    
    return DOM.div(
        document,
        button, 
        DOM.h1("Hello World", style=map(x-> "color: $(x)", color)),
        scene
    )
end


isdefined(Main, :server) && close(server)

server = JSServe.Server(app, "127.0.0.1", 8080)

HTML("""
<iframe src="http://localhost:8080" width="800" height="800"></iframe>
""")