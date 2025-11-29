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
		width:         600
		height:        600
		create_window: true
		window_title:  '-Test plot-'
		bg_color:      gg.gray
		user_data:     app
		frame_fn:      on_frame
		sample_count:  4
	)
	precision := 100
	start := 0
	end := 2
	f := fn [start, end, precision] (id f32) f32{
		return plot.linear_interpolation(start, end, id, precision)
	}
	app.dia = plot.plot([[]f32{len: precision, init: f(index)}, []f32{len: precision, init: f(index)}], [[]f32{len: precision, init: f(index) * f(index)}, []f32{len: precision, init: f(index) * f(index) * f(index)}],
		[gg.red, gg.blue], [0, 0])
	app.dia.change_pos(10, 10)
	app.dia.change_size(400, 400)

	app.ctx.run()
}

fn on_frame(mut app App) {
	app.ctx.begin()
	app.dia.render(app.ctx)
	app.ctx.end()
}
