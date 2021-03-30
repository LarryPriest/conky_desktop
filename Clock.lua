--[[ Clock.lua  is the testing ground for lua scripts (heavy cairo)
I found the the tut. from http://crunchbang.org/forums/viewtopic.php?id=17246
    mrpeachy  provided the tutorial.
this is a lua script for use in conky.  you call it with:
### Lua scriopt invocation
lua_load ~/scripts/Clock.lua
lua_draw_hook_pre Clock_main
###
assuming this script is in /home/$username/scripts
but you can put it where you like. just make sure the path is correct or lua
spits a nil call to Clock_main Other notes to follow:
-- Set up the colours here colours are rgb and alpha are between 0 and 1 
alpha is 0 transparent 1 is solid
rgb is like 245/255, 233/255, 112/255
easy enough to switch between decimal and hex 
but the fraction is weird do-able but weird
--]]
require 'cairo'
-- print ("Setup colours for Clock.lua")
-- ###########################
-- font colour
-- DarkTurqoise RGBA 0,206,209,1
Dark_turq={ red=0, green=206/255, blue=209/255, alpha=1 }
-- white fill colour 255 255 255
White={ red=1, green=1, blue=1, alpha=1 }
Black={ red=0, green=0, blue=0, alpha=1 }
-- red line colour 255 0 0
Red={ red=1, green=0, blue=0, alpha=1 }
-- 47  79  79		DarkSlateGray
DarkSlateGray={ red=47/255, green=79/255, blue=79/255, alpha=1 }
-- burnt orange --> Red	204 Green	85 Blue	0
Burnt_Orange={ red=204/255, green=85/255, blue=38/255, alpha=1 }

-- #############################################
-- setup some defaults
--
-- font defaults to my choice
font="DejaVu Sans Mono"
font_size = 16  -- something funky with font size does not look right?
font_slant = CAIRO_FONT_SLANT_NORMAL --NORMAL or BOLD
font_face = CAIRO_FONT_WEIGHT_NORMAL --normal or ITALIC
font_colour = White
-- colour defaults to white obaque
default_red = 1 ; default_green = 1 ;default_blue = 1 ; default_alpha = 1
default_colour = { red=default_red, green=default_green, blue=default_blue, 
                   alpha=default_alpha}
none_def={ alpha=1 } -- can't remember what this is for

-- ##############################################
-- Clock setup starts here
clockline=5
clock_radius=120
clockx=clock_radius+(2*clockline)+font_size
clocky=clock_radius+(2*clockline)+font_size
clockstart=0
clockend=2*math.pi

clock_colour = Burnt_Orange
--gap from clock border to hour marks
b_to_m=5
--set mark length
m_length=10
--set mark line width
m_width=3
--set mark line cap type
m_cap=CAIRO_LINE_CAP_ROUND
--set mark color and alpha,red blue green alpha
mark_colour = White

--seconds hand setup
--set length of seconds hand
sh_length=95
--set hand width
sh_width=1
--set hand line cap
sh_cap=CAIRO_LINE_CAP_ROUND
--set seconds hand color
second_hand_colour = Red

--minutes hand setup
--set length of minutes hand
mh_length=90
--set hand width
mh_width=4
--set hand line cap
mh_cap=CAIRO_LINE_CAP_ROUND
--set minute hand color
minute_hand_colour = White
--hour hand setup
--set length of hour hand
hh_length=60
--set hand width
hh_width=7
--set hand line cap
hh_cap=CAIRO_LINE_CAP_ROUND
--set hour hand color
hour_hand_colour = White

-- ######################################
-- -Coding starts here  -----------------------------
-- functions first, could go last?                 ---

function Get_XY ( rad, deg)
    if rad == nil then return end
        point_t = ( math.pi / 180 ) * deg -- don't want to do this calc twice
        x = 0 + rad * ( math.sin ( point_t ) )
        y = 0 - rad * ( math.cos ( point_t ) )
    return x, y
end --End of Get_XY

--++++++++++++++++++++++++++              ++++++++++++ ----
function Draw_Hand ( radius, line_width, line_cap, degrees, Colour )
    if radius == nil then return end -- bail if no radius ( line length )
    if Colour.red == nil then Colour = default_colour end
    -- default white colour
    --set our starting line coordinates, the center of the circle
    cairo_move_to ( cr, clockx, clocky )
    --calculate coordinates for end of hand
    x , y = Get_XY( radius, degrees )
    --describe the line we will draw
    cairo_line_to (cr, clockx + x, clocky + y )
    --set up line attributes and draw line
    cairo_set_line_width (cr, line_width )
    cairo_set_source_rgba(cr,Colour.red,Colour.green,Colour.blue, Colour.alpha)
    cairo_set_line_cap  (cr, line_cap )
    cairo_stroke (cr)
end --End of Draw_Hand
--++++++++++++++++++++++++++                ++++++++++ ----

function Clock_Tick ()
--[[ Clock_Tick()
Time calculations This function calculates the seconds (degrees for each hand) 
and passess that to the Draw_Hand function to do the drawing. Some lines have
been consolidated. In most cases the original line is left commented out.
hours=tonumber(os.date("%I"))-- %I -12 hour clock & 
tonumber to make sure is a number
    --convert hours to seconds
--]]
    h_to_s = 60 * 60 * tonumber(os.date("%I"))
--  minutes=tonumber(os.date("%M")) 
    --convert minutes to seconds
    m_to_s = 60 * tonumber(os.date("%M"))
    --get current seconds
    seconds = tonumber(os.date("%S"))
    --++++ add them all together  ++++++++++++++--
    --calculate degrees for the hour hand each second
    hsec_degs = ( h_to_s + m_to_s + seconds ) * (360/43200)
    --[[ using an eq_n instead of typing the calculation straight in because 
the result of 360/43200 gave us decimal places - fine movement of hour hand 
-- 360 degs in a circle and for the hour hand one circle has 
12*60*60 = 43200 seconds 
     --]]
    --calculate degrees for the minute hand each second
    msec_degs = ( m_to_s + seconds ) * 0.1 
-- minutes in seconds x 360 degrees / 3600 seconds 
    -- calculate degrees for the second hand each second
    sec_degs = seconds * 6
-- ++++++ Everything has been calculated so Draw_Hand draws the Hours Hand ++---       
    Draw_Hand ( hh_length, hh_width, hh_cap, hsec_degs, hour_hand_colour)
    -- Draw the minute hand 
    Draw_Hand ( mh_length, mh_width, mh_cap, msec_degs, minute_hand_colour)
    --Draw seconds hand
    Draw_Hand ( sh_length, sh_width, sh_cap, sec_degs, second_hand_colour)

end -- Clock_Tick
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--------
-- Main function  Clock_main starts here   - Hang on to yourunderwear    ------
--
function conky_Clock_main()

if conky_window == nil then 
    return
end -- if conky did not set up a window bail
local cs= cairo_xlib_surface_create(conky_window.display,
			                        conky_window.drawable,
                                    conky_window.visual,
                                    conky_window.width,
                                    conky_window.height)
cr = cairo_create(cs)
--    local updates=tonumber(conky_parse('${updates}')) 
-- enable this local var and the if block for statistics display
--    if updates>5 then  -- this waits for 5 update intervals 
                       -- why? mainly for statistic displays
    --##############################
    -- draw the circle
cairo_set_line_width (cr, clockline)
Colour=clock_colour
cairo_set_source_rgba(
                    cr,Colour.red,Colour.green,Colour.blue,Colour.alpha)
cairo_arc ( cr, clockx, clocky, clock_radius, clockstart , clockend )
cairo_close_path (cr)
cairo_stroke (cr)
--+++++++++++++ Write some numbers around the clock  
cairo_select_font_face (cr, font, font_slant, font_face);
cairo_set_font_size (cr, font_size)
cairo_select_font_face (cr, font, font_slant, font_face);
cairo_set_font_size (cr, font_size)
cairo_set_source_rgba ( cr, font_colour.red, font_colour.green,
                                  font_colour.blue, font_colour.alpha )
ti=12     
cairo_move_to (cr,clockx - font_size/2,clocky-clock_radius-font_size/2)
cairo_show_text (cr, ti )
cairo_stroke (cr)
ti=3     
cairo_move_to(cr,clockx+clock_radius + font_size/2,clocky + font_size/2)
cairo_show_text (cr, ti )
cairo_stroke (cr)
ti=6    
cairo_move_to(cr,clockx - font_size/2,clocky + clock_radius + font_size)
cairo_show_text (cr, ti )
cairo_stroke (cr)
ti=9     
cairo_move_to(cr,clockx - clock_radius - font_size,clocky + font_size/2)
cairo_show_text (cr, ti )
cairo_stroke (cr)

-- +++++ this section does clock ticks not tocks  ++++++++++++++++++++------
--calculate end and start radius for marks -- done here so variable clock size
m_end_rad = clock_radius - b_to_m
m_start_rad = m_end_rad - m_length
font_radius = clock_radius 
--set line cap type
cairo_set_line_cap  ( cr, m_cap)
--set line width
cairo_set_line_width ( cr, m_width)
--start for loop
for i=0,11 do
    --using the value of i to calculate degrees
    --calculate start point for 12 oclock mark
    -- 12 ticks 360 degrees therefore one every 30 degrees
    x,y = Get_XY ( m_start_rad, ( ( i  ) * 30 ) )
    --set start point for line
    cairo_move_to ( cr, clockx + x, clocky + y )
    --calculate end point for 12 oclock mark
    x,y = Get_XY ( m_end_rad, ( ( i ) * 30 ) )
    cairo_set_line_cap ( cr, m_cap)
    --set line width
    cairo_set_line_width ( cr, m_width)
    --set path for line
    cairo_line_to ( cr, clockx + x, clocky + y )
    --set color and alpha for marks
    cairo_set_source_rgba(cr,mark_colour.red,mark_colour.
                     green,mark_colour.blue,mark_colour.alpha )
    --draw the line
    cairo_stroke (cr)

end--of for loop
Clock_Tick()

--    end-- if updates>5

-- wipe out the surface
--	print "Hello world!"
cairo_destroy(cr)
cairo_surface_destroy(cs)
cs=nil
cr=nil -- release var cr
end-- end main function
