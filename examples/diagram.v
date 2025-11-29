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
	total := 300
	app.dia = plot.plot([[]f32{len: total, init: index}, []f32{len: total, init: index}], [[]f32{len: total, init: index * index}, []f32{len: total, init: index * index * index}],
		[gg.red, gg.blue])
	app.dia.change_pos(10, 10)
	app.dia.change_size(400, 400)

	app.ctx.run()
}

fn on_frame(mut app App) {
	app.ctx.begin()
	app.dia.render(app.ctx)
	app.ctx.end()
}
