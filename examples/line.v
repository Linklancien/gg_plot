import linklancien.gg_plot
import gg

fn main() {
	mut ctx := gg.new_context(
		fullscreen:    false
		width:         600
		height:        600
		create_window: true
		window_title:  '-Test plot-'
		bg_color:      gg.gray
		// user_data:     app
		frame_fn:     on_frame
		sample_count: 4
	)
	ctx.run()
}

fn on_frame(mut ctx gg.Context) {
	abscise := []f32{len: 100, init: index}
	value := []f32{len: 100, init: index * index}
	ctx.begin()
	gg_plot.render_raw_graph(ctx, 20.0, 20.0, 500, 500, abscise, value, 'Test plot: x**2')
	ctx.end()
}
