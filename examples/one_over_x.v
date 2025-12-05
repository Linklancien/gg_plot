import linklancien.gg_plot
import gg

struct App {
mut:
	ctx &gg.Context = unsafe { nil }
	dia gg_plot.Diagram
}

fn main() {
	mut app := &App{}
	app.ctx = gg.new_context(
		fullscreen:    false
		width:         100 * 9
		height:        100 * 6
		create_window: true
		window_title:  '-Test gg_plot-'
		bg_color:      gg.white
		user_data:     app
		frame_fn:      on_frame
		sample_count:  4
	)
	precision1 := 40
	start1 := f32(0)
	end1 := 3

	f := fn [start1, end1, precision1] (id f32) f32 {
		return gg_plot.linear_interpolation(start1, end1, id, precision1)
	}
	app.dia = gg_plot.plot([[]f32{len: precision1 + 1, init: f(index)}], [
		[]f32{len: precision1 + 1, init: 1 / f(index)},
	], [gg.red])

	app.dia.change_pos(150, 50)
	app.dia.change_size(600, 500)
	app.dia.border_size(40)
	app.dia.corner_size(30)
	app.dia.title('x square and cube ')

	app.dia.x_label('x')
	app.dia.y_label('Somme power of x')
	app.dia.set_scale(-1, 4, 1, 15)
	// app.dia.autosacling()

	app.ctx.run()
}

fn on_frame(mut app App) {
	app.ctx.begin()
	app.dia.render(app.ctx)
	app.ctx.end()
}
