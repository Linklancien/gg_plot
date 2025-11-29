import linklancien.plot
import gg

struct App {
mut:
	ctx &gg.Context = unsafe { nil }
	dia plot.Diagram
}

fn main() {
	mut app := &App{}
	app.ctx = gg.new_context(
		fullscreen:    false
		width:         100 * 9
		height:        100 * 6
		create_window: true
		window_title:  '-Test plot-'
		bg_color:      gg.white
		user_data:     app
		frame_fn:      on_frame
		sample_count:  4
	)
	precision := 100
	start := 0
	end := 2
	f := fn [start, end, precision] (id f32) f32 {
		return plot.linear_interpolation(start, end, id, precision)
	}
	app.dia = plot.plot([[]f32{len: precision + 1, init: f(index)},
		[]f32{len: precision + 1, init: f(index)}], [[]f32{len: precision + 1, init: f(index) * f(index)},
		[]f32{len: precision + 1, init: f(index) * f(index) * f(index)}], [gg.red, gg.blue],
		[0, 0])
	app.dia.change_pos(150, 50)
	app.dia.change_size(600, 500)
	app.dia.border_size(30)
	app.dia.corner_size(30)

	app.ctx.run()
}

fn on_frame(mut app App) {
	app.ctx.begin()
	app.dia.render(app.ctx)
	app.ctx.end()
}
