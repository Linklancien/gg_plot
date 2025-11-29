module gg_plot

import gg
import arrays { max, min }
import math { round_sig }

const cfg_x_axe = gg.TextCfg{
	align:          .center
	vertical_align: .middle
}
const cfg_y_axe = gg.TextCfg{
	align:          .right
	vertical_align: .middle
}
const signigicant_numbers = 3

// render_graph creat a graph at x, y with a width of w and an height of h
pub fn render_raw_graph(ctx gg.Context, x f32, y f32, w f32, h f32, abscisse []f32, value []f32, name string) {
	max := max(value) or { panic('No max value') }
	min := min(value) or { panic('No min value') }
	max_a := max(abscisse) or { panic('No max abscisse') }

	f := fn [max, min, y, h] (value f32) f32 {
		return y + h - h * (value - min) / (max - min)
	}

	mut render_max := true
	mut render_min := true
	// Some magic numbers
	ctx.draw_rounded_rect_filled(f32(x - 10), f32(y - 10), f32(w + 35), f32(h + 10 + 35),
		5, gg.dark_gray)
	for k in 0 .. (abscisse.len - 1) {
		ctx.draw_line(f32(x + w * abscisse[k] / max_a), f32(f(value[k])), f32(x + w * abscisse[k +
			1] / max_a), f32(f(value[k + 1])), gg.red)
		if k == 0 || k == abscisse.len - 2 {
			ctx.draw_text_def(int(x + w * abscisse[k] / max_a), int(f(value[k])), 'x: ${abscisse[k]}  y: ${value[k]}')
			if value[k] == min {
				render_min = false
			}
			if value[k] == max {
				render_max = false
			}
		} else if value[k] == max && render_max {
			ctx.draw_text_def(int(x + w * abscisse[k] / max_a), int(f(value[k])), 'x: ${abscisse[k]}  y: ${value[k]}')
			render_max = false
		} else if value[k] == min && render_min {
			ctx.draw_text_def(int(x + w * abscisse[k] / max_a), int(f(value[k])), 'x: ${abscisse[k]}  y: ${value[k]}')
			render_min = false
		}
	}
	// ctx.draw_text_def(int(x), int(f(value[0])), '${value[0]}')
	// ctx.draw_text_def(int(x + w), int(f(value[abscisse.len - 1])), '${value[abscisse.len - 1]}')
	ctx.draw_text_def(int(x + w / 2), int(y + h + 10), name)
}

// utility
pub fn linear_interpolation(a f32, b f32, k f32, n f32) f32 {
	return a + (b - a) * k / n
}

//
// a: global position
// b: value the will be plot
// c: visuals
pub struct Diagram {
mut:
	// a:
	pos  Pos
	size Pos = Pos{
		x: 10
		y: 10
	}

	// b:
	abscisses [][]f32
	values    [][]f32
	colors    []gg.Color

	// c:
	grid       Grid
	background gg.Color = gg.white
	border     f32      = 10
	corner     f32      = 5
	title      Label
	x_label    Label
	y_label    Label
}

struct Pos {
	x f32
	y f32
}

struct Label {
mut:
	text string
	cfg  gg.TextCfg = gg.TextCfg{
		align:          .center
		vertical_align: .middle
	}
}

struct Grid {
	color gg.Color = gg.black
	x     bool     = true
	x_nb  int      = 5
	y     bool     = true
	y_nb  int      = 5
}

// creation
// basic creation
pub fn plot(abscisses [][]f32, values [][]f32, colors []gg.Color) Diagram {
	assert abscisses.len == values.len, "Len of abscisses and values doesn't match"
	assert abscisses.len == colors.len, "Len of abscisses and colors doesn't match"
	return Diagram{
		abscisses: abscisses
		values:    values
		colors:    colors
	}
}

// changes
pub fn (mut dia Diagram) change_pos(x f32, y f32) {
	dia.pos = Pos{
		x: x
		y: y
	}
}

pub fn (mut dia Diagram) change_size(w f32, h f32) {
	dia.size = Pos{
		x: w
		y: h
	}
}

pub fn (mut dia Diagram) add_curve(abscisse []f32, value []f32, color gg.Color) {
	dia.abscisses << abscisse
	dia.values << value
	dia.colors << color
}

pub fn (mut dia Diagram) show_grid(to_show bool) {
	dia.grid = Grid{
		x: to_show
		y: to_show
	}
}

pub fn (mut dia Diagram) title(text string) {
	dia.title.text = text
}

pub fn (mut dia Diagram) x_label(text string) {
	dia.x_label.text = text
}

pub fn (mut dia Diagram) y_label(text string) {
	dia.y_label.text = text
}

pub fn (mut dia Diagram) border_size(border f32) {
	dia.border = border
}

pub fn (mut dia Diagram) corner_size(corner f32) {
	dia.corner = corner
}

// rendering
pub fn (dia Diagram) render(ctx gg.Context) {
	max_x, max_y := dia.get_max_dim()
	min_x, min_y := dia.get_min_dim()
	// draw back
	ctx.draw_rounded_rect_filled(dia.pos.x, dia.pos.y, dia.size.x, dia.size.y, dia.corner,
		dia.background)
	// draw grid
	if dia.grid.x {
		dia.render_x_grid(ctx, min_x, max_x, min_y, max_y)
	}
	if dia.grid.y {
		dia.render_y_grid(ctx, min_x, max_x, min_y, max_y)
	}
	// draw curves

	max_abs, max_val := dia.get_max()
	min_abs, min_val := dia.get_min()

	for id in 0 .. dia.abscisses.len {
		render_curve(ctx, min_x, max_x, min_y, max_y, min_abs, max_abs, min_val, max_val,
			dia.abscisses[id], dia.values[id], dia.colors[id])
	}
	// draw axes values
	dia.render_axes(ctx, min_x, max_x, min_y, max_y, min_abs, max_abs, min_val, max_val)

	// draw labels
	dia.render_labels(ctx, min_x, max_x, min_y, max_y)
}

fn (dia Diagram) get_max_dim() (f32, f32) {
	max_x := dia.pos.x + dia.size.x - dia.border
	max_y := dia.pos.y + dia.size.y - dia.border
	return max_x, max_y
}

fn (dia Diagram) get_min_dim() (f32, f32) {
	min_x := dia.pos.x + dia.border
	min_y := dia.pos.y + dia.border
	return min_x, min_y
}

// draw grid
fn (dia Diagram) render_x_grid(ctx gg.Context, min_x f32, max_x f32, min_y f32, max_y f32) {
	total := dia.grid.x_nb

	f := fn [min_x, max_x, total] (value f32) f32 {
		return linear_interpolation(min_x, max_x, value, total)
	}

	for i in 0 .. (total + 1) {
		x := f(i)
		ctx.draw_line(x, min_y, x, max_y, dia.grid.color)
	}
}

fn (dia Diagram) render_y_grid(ctx gg.Context, min_x f32, max_x f32, min_y f32, max_y f32) {
	total := dia.grid.y_nb

	f := fn [min_y, max_y, total] (value f32) f32 {
		return linear_interpolation(min_y, max_y, value, total)
	}

	for i in 0 .. (total + 1) {
		y := f(i)
		ctx.draw_line(min_x, y, max_x, y, dia.grid.color)
	}
}

// draw curves
fn (dia Diagram) get_max() (f32, f32) {
	mut max_abs := max(dia.abscisses[0]) or { panic('No abs') }
	mut max_val := max(dia.values[0]) or { panic('No val') }
	for i in 1 .. dia.abscisses.len {
		local_abs := max(dia.abscisses[i]) or { panic('No abs') }
		max_abs = f32_max(local_abs, max_abs)
		local_val := max(dia.values[i]) or { panic('No val') }
		max_val = f32_max(max_val, local_val)
	}
	return max_abs, max_val
}

fn (dia Diagram) get_min() (f32, f32) {
	mut min_abs := min(dia.abscisses[0]) or { panic('No abs') }
	mut min_val := min(dia.values[0]) or { panic('No val') }
	for i in 1 .. dia.abscisses.len {
		local_abs := min(dia.abscisses[i]) or { panic('No abs') }
		min_abs = f32_min(local_abs, min_abs)
		local_val := min(dia.values[i]) or { panic('No val') }
		min_val = f32_min(min_val, local_val)
	}
	return min_abs, min_val
}

fn render_curve(ctx gg.Context, min_x f32, max_x f32, min_y f32, max_y f32, min_abs f32, max_abs f32, min_val f32, max_val f32, abscisse []f32, value []f32, color gg.Color) {
	f_x := fn [min_x, max_x, min_abs, max_abs] (abs f32) f32 {
		return linear_interpolation(min_x, max_x, abs - min_abs, max_abs - min_abs)
	}

	f_y := fn [min_y, max_y, min_val, max_val] (value f32) f32 {
		return linear_interpolation(max_y, min_y, value - min_val, max_val - min_val)
	}

	for k in 0 .. (abscisse.len - 1) {
		x1 := f_x(abscisse[k])
		x2 := f_x(abscisse[k + 1])
		y1 := f_y(value[k])
		y2 := f_y(value[k + 1])
		ctx.draw_line(x1, y1, x2, y2, color)
	}
}

// draw axes values
fn (dia Diagram) render_axes(ctx gg.Context, min_x f32, max_x f32, min_y f32, max_y f32, min_abs f32, max_abs f32, min_val f32, max_val f32) {
	// x
	total_x := dia.grid.x_nb

	f_x := fn [min_x, max_x, total_x] (value f32) int {
		return int(linear_interpolation(min_x, max_x, value, total_x))
	}

	f_abs := fn [min_abs, max_abs, total_x] (value f32) f32 {
		return linear_interpolation(min_abs, max_abs, value, total_x)
	}

	for i in 0 .. (total_x + 1) {
		x := f_x(i)
		text_abs := '${round_sig(f_abs(i), signigicant_numbers)}'
		ctx.draw_text(x, int(max_y + dia.border / 2), text_abs, cfg_x_axe)
	}
	// y
	total_y := dia.grid.y_nb

	f_y := fn [min_y, max_y, total_y] (value f32) int {
		return int(linear_interpolation(min_y, max_y, value, total_y))
	}

	f_val := fn [min_val, max_val, total_y] (value f32) f32 {
		return linear_interpolation(max_val, min_val, value, total_y)
	}

	for i in 0 .. (total_y + 1) {
		y := f_y(i)
		text_val := '${round_sig(f_val(i), signigicant_numbers)}'
		ctx.draw_text(int(min_x - dia.border / 2), y, text_val, cfg_y_axe)
	}
}

fn (dia Diagram) render_labels(ctx gg.Context, min_x f32, max_x f32, min_y f32, max_y f32) {
	x_title := int((min_x + max_x) / 2)
	y_title := int(min_y - dia.border / 2)
	ctx.draw_text(x_title, y_title, 
	dia.title.text, dia.title.cfg)
}
