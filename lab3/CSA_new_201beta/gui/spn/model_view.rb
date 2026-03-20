#
# gui/spn/model_view.rb - SPN model view including editor
#
# $Id: model_view.rb,v 1.3 2006/07/20 11:22:33 pac Exp $
#

module GUI
   require "gui/fox"

   module SPN

      class PetriModelView < ModelView
         require "objects/spn/wizards"

         def drawNode(dc, node)
            node.nx = @event.win_x unless node.nx
            node.ny = @event.win_y unless node.ny
            node.w = (node.kind_of?(Objects::SPN::Transition) ? 15 : 30) unless node.w
            node.h = 30 unless node.h
            x, y = node.nx, node.ny
            w, h = node.w, node.h

            font = FXFont.new(FXApp::instance, "times", 10, FONTWEIGHT_BOLD)
            font.create
            dc.font = font
            if node.instance_of? Objects::SPN::Place
               dc.setForeground(FXRGB(255, 0, 0))
               dc.drawArc(x, y, w, h, 0, 64*360)
            elsif node.instance_of? Objects::SPN::Transition
               dc.setForeground(FXRGB(0, 0, 0))
               dc.fillRectangle(x, y, w, h)
            elsif node.instance_of? Objects::SPN::SuperTransition
               dc.setForeground(FXRGB(0, 0, 0))
               dc.drawRectangle(x, y, w, h)
            end
            begin
               dc.drawText(x, y - 8, node.name)
            rescue
               dc.drawText(x, y - 8, node.name, node.name.length)
            end
         end # drawNode

         def drawArc(dc, arc)
            dc.setForeground(FXRGB(0, 255, 0))
            arc.w = 10 unless arc.w
            arc.h = 10 unless arc.h
            s_x, s_y = arc.source.nx + arc.source.w / 2, arc.source.ny + arc.source.h / 2
            d_x, d_y = arc.dest.nx + arc.dest.w / 2, arc.dest.ny + arc.dest.h / 2

            unless arc.nx or arc.ny
               med_x = (s_x + d_x) / 2
               med_y = (s_y + d_y) / 2
               arc.nx = med_x - arc.w / 2
               arc.ny = med_y - arc.h / 2
            end

            w, h = arc.w, arc.h
            s_dx = arc.nx + w / 2 - s_x + 0.0001
            s_dy = arc.ny + w / 2 - s_y + 0.0001
            s_alpha = s_dy / s_dx
            sign_sdx = (0 <= s_dx ? 1 : -1)
            s_sin = s_alpha / Math.sqrt(1 + s_alpha * s_alpha) * sign_sdx
            s_cos = 1 / Math.sqrt(1 + s_alpha * s_alpha) * sign_sdx
            if arc.source.kind_of? Objects::SPN::Transition
               if arc.source.rotated
                  s_x += arc.source.w / 2 * (s_x > arc.nx ? -1 : 1)
                  s_y += 0
               else
                  s_x += 0
                  s_y += arc.source.h / 2 * (s_y > arc.ny ? -1 : 1)
               end
            else
               s_x += arc.source.w / 2 * s_cos
               s_y += arc.source.w / 2 * s_sin
            end
            dc.drawLine(s_x, s_y, arc.nx + w / 2, arc.ny + h / 2)

            d_dx = d_x - arc.nx + w / 2 + 0.0001
            d_dy = d_y - arc.ny + h / 2
            d_alpha = d_dy / d_dx
            sign_ddx = (0 <= d_dx ? 1 : -1)
            d_sin = d_alpha / Math.sqrt(1 + d_alpha * d_alpha) * sign_ddx
            d_cos = 1 / Math.sqrt(1 + d_alpha * d_alpha) * sign_ddx
            if arc.dest.kind_of? Objects::SPN::Transition
               if arc.dest.rotated
                  d_x -= arc.dest.w / 2 * (d_x < arc.nx ? -1 : 1)
                  d_y -= 0
               else
                  d_x -= 0
                  d_y -= arc.dest.h / 2 * (d_y < arc.ny ? -1 : 1)
               end
            else
               d_x -= arc.dest.w / 2 * d_cos
               d_y -= arc.dest.w / 2 * d_sin
            end

            dc.drawLine(arc.nx + w / 2, arc.ny + h / 2, d_x, d_y)

            dc.drawRectangle(arc.nx, arc.ny, w, h) if Objects::Link::showMarks
         
            a_edge = Math::sqrt(250)
            a_sin  = 5 / a_edge
            a_cos  = 15 / a_edge
            a_lx   = a_edge * (a_cos * d_cos - a_sin * d_sin)
            a_ly   = a_edge * (a_sin * d_cos + a_cos * d_sin)
            a_rx   = a_edge * (a_cos * d_cos + a_sin * d_sin)
            a_ry   = a_edge * (-a_sin * d_cos + a_cos * d_sin)
            dc.fillPolygon([FXPoint.new(d_x.to_i, d_y.to_i),
                            FXPoint.new((d_x - a_lx).to_i, (d_y - a_ly).to_i),
                            FXPoint.new((d_x - a_rx).to_i, (d_y - a_ry).to_i)])
         end # drawArc

      end # class PetriModelView

   end # module SPN

end # module GUI
