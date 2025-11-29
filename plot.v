module plot

import gg
import arrays { max, min }

// render_graph creat a graph at x, y with a width of w and an height of h
pub fn render_raw_graph(ctx gg.Context, x f32, y f32, w f32, h f32, abscise []f32, value []f32, name string) {
	max := max(value) or { panic('No max value') }
	min := min(value) or { panic('No min value') }
	max_a := max(abscise) or { panic('No max abscise') }

	f := fn [max, min, y, h] (value f32) f32 {
		return y + h - h * (value - min) / (max - min)
	}

	mut render_max := true
	mut render_min := true
	// Some magic numbers
	ctx.draw_rounded_rect_filled(f32(x - 10), f32(y - 10), f32(w + 35), f32(h + 10 + 35),
		5, gg.dark_gray)
	for k in 0 .. (abscise.len - 1) {
		ctx.draw_line(f32(x + w * abscise[k] / max_a), f32(f(value[k])), f32(x + w * abscise[k +
			1] / max_a), f32(f(value[k + 1])), gg.red)
		if k == 0 || k == abscise.len - 2 {
			ctx.draw_text_def(int(x + w * abscise[k] / max_a), int(f(value[k])), 'x: ${abscise[k]}  y: ${value[k]}')
			if value[k] == min {
				render_min = false
			}
			if value[k] == max {
				render_max = false
			}
		} else if value[k] == max && render_max {
			ctx.draw_text_def(int(x + w * abscise[k] / max_a), int(f(value[k])), 'x: ${abscise[k]}  y: ${value[k]}')
			render_max = false
		} else if value[k] == min && render_min {
			ctx.draw_text_def(int(x + w * abscise[k] / max_a), int(f(value[k])), 'x: ${abscise[k]}  y: ${value[k]}')
			render_min = false
		}
	}
	// ctx.draw_text_def(int(x), int(f(value[0])), '${value[0]}')
	// ctx.draw_text_def(int(x + w), int(f(value[abscise.len - 1])), '${value[abscise.len - 1]}')
	ctx.draw_text_def(int(x + w / 2), int(y + h + 10), name)
}

// utility
fn linear_interpolation(a f32, b f32, k f32, n f32)f32{
	return a + (b - a)*k/n
}

//
// a: global position
// b: value the will be plot
// c: visuals
struct Diagram {
mut:
	// a:
	pos  struct {
		x f32
		y f32
	}
	size struct {
		w f32
		h f32
	}

	// b:
	abscises [][]f32
	values   [][]f32
	colors   []gg.Color

	// c:
	grid       struct {
		color gg.Color = gg.Black
		x     bool     = true
		x_nb  int      = 5
		y     bool     = true
		y_nb  int      = 5
	}
	background gg.Color = gg.dark_gray
	border     f32      = 10
	corner     f32      = 5
	title      Label
	x_label    Label
	y_label    Label
}

struct Label {
mut:
	text string
	cfg  gg.TextCfg
}

// creation
// basic creation
pub fn plot(abscises [][]f32, values [][]f32, colors []gg.Color) Diagram {
	assert abscise.len == values.len, 'Not enougth values or abscices'
	return Diagram{
		abscises: abscises
		values:   values
		colors:   colors
	}
}

// changes
pub fn (dia Diagram) add_curve(abscise []f32, value []f32, color gg.Color) {
	dia.abscises << abscise
	dia.values << value
	dia.colros << color
}

pub fn (dia Diagram) show_grid(to_show bool) {
	dia.grid = {
		x: to_show
		y: to_show
	}
}

pub fn (dia Diagram) title(text string) {
	dia.title.text = text
}

pub fn (dia Diagram) x_label(text string) {
	dia.x_label.text = text
}

pub fn (dia Diagram) y_label(text string) {
	dia.y_label.text = text
}

pub fn (dia Diagram) border_size(border f32) {
	dia.border = border
}

// rendering
pub fn (dia Diagram) render(ctx gg.Context) {
	// draw back
	ctx.draw_rounded_rect_filled(dia.pos.x, dia.pos.y, dia.pos.w, dia.pos.h, dia.corner,
		dia.background)
	// draw grid
	if dia.grid.x {
		dia.render_x_grid(ctx)
	}
	if dia.grid.y {
		dia.render_y_grid(ctx)
	}
	// draw curves
	max_x := dia.pos.x + dia.w - dia.border
	min_x := dia.pos.x + dia.border

	max_y := dia.pos.y + dia.h - dia.border
	min_y := dia.pos.y + dia.border
	for id in dia.abscices.len {
		render_curve(ctx, min_x, max_x, min_y, max_y, dia.abscices[i], dia.values[i],
			dia.colors)
	}
	// draw axes

	// draw labels
}

fn (dia Diagram) render_x_grid(ctx gg.Context) {
	max_x := dia.pos.x + dia.w - dia.border
	min_x := dia.pos.x + dia.border

	max_y := dia.pos.y + dia.h - dia.border
	min_y := dia.pos.y + dia.border

	total := dia.grid.x_nb

	f := fn [min_x, max_x, total] (value f32) f32 {
		return linear_interpolation(min_x, max_x, value, total)
	}

	for i in 0 .. total {
		x := f(i)
		ctx.draw_line(x, min_y, x, max_y, dia.grid.color)
	}
}

fn (dia Diagram) render_y_grid(ctx gg.Context) {
	max_x := dia.pos.x + dia.w - dia.border
	min_x := dia.pos.x + dia.border

	max_y := dia.pos.y + dia.h - dia.border
	min_y := dia.pos.y + dia.border

	total := dia.grid.x_nb

	f := fn [min_y, max_y, total] (value f32) f32 {
		return linear_interpolation(min_y, max_y, value, total)
	}

	for i in 0 .. total {
		y := f(i)
		ctx.draw_line(min_x, y, max_x, y, dia.grid.color)
	}
}

fn render_curve(ctx gg.Context, min_x f32, max_x f32, min_y f32, max_y f32, abscice gg.Color, value gg.Color, color gg.Color) {
	f_x := fn [min_x, max_x] (value f32) f32 {
		return y + h - h * (value - min) / (max - min)
	}

	f_y := fn [min_y, max_y] (value f32) f32 {
		return min_y + (max_y - min_y)*value/max_value
	}

	f32(x + w * abscise[k] / max_a), f32(f(value[k])), f32(x + w * abscise[k +
			1] / max_a), f32(f(value[k + 1]))

	for k in 0 .. (abscise.len - 1) {
		x1 := 
		x2 := 
		y1 := 
		y2 := 
		ctx.draw_line(x, y, x2, y2, color)
	}
}
