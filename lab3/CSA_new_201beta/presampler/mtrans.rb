#
#  presampler/mtrans.rb 
#  v 1.40  2008/09/01
#
#  == работа с Sampler-отчетом:
#    - ModelTransform [class]
#        - samplerReport2samplerTable(smp_rep)
#          == Парсинг Sampler-репорта
#    - samplerGraph2arcGraph(samplerModel, samplerTable)
#      == " Нагружение УГП данными Sampler-репорта "
#         (Сборка ГНД программы из УГП и отчета Sampler-а()
#    - coverPartition(samplerGraph)
#      == " Рассчет покрытия графа"
#          (общее количество дуг, количество ненагруженных)

require 'strscan'
require "objects/sampler_graph/model"

require "objects/amc/model"
require "gui/main_window"

class ModelTransform
  attr_accessor :samplerTable

  #***********************************************************************
  private
    # Парсинг одной строчки Sampler-репорта
    # Вход:  s - КОРРЕКТНАЯ строчка Sampler-репорта
    # Выход: хэш с распарсенными строковыми значениями
    def saplerLine2numbStrs(s)
      numbs = s.scan(/\d+/)
      return {
        :src => numbs[1],
        :dst => numbs[3],
        :t_all  => numbs[4]+"."+numbs[5],
        :count => numbs[6],
        :t_one => numbs[numbs.length-2]+"."+numbs[numbs.length-1]
      }
    end #def saplerLine2numbStrs

  #***********************************************************************
  private
    # Преобразование распарсенных строковых значений Sampler-репорта...
    # в  "удобную" форму
    # Вход:  numbStrsHash - хэш с распарсенными строковыми значениями
    # Выход: пара <имя перехода> <параметры перехода>
    def numbStrs2samplerJumpInfo(numbStrsHash)
      h = numbStrsHash
      jump  = h[:src] + "->" +  h[:dst]
      time  = h[:t_one].to_f
      count = h[:count].to_i

      return jump, {:time => time, :count => count}
    end #def numbStrs2samplerJumpInfo(numbStrsHash)

  #***********************************************************************
  public
    # Парсинг Sampler-репорта
    # Вход:  smp_rep - текст КОРРЕКТНОГО Sampler-репорта (см. подробнее WARNING)
    # Выход: @samplerTable - Хеш-таблица в формате:
    #      ключ     - <имя перехода> ~~ "t1->t2"
    #      значение - <параметры перехода> ~~
    #         ~~ {:time => <время-число>, :count => <количество-число>}
    def samplerReport2samplerTable(smp_rep)
      @samplerTable = Hash.new
      goodLine = true

      # WARNING !!!
      # узкое место - парсинг критичен к ФОРМАТУ Sampler-реорта:
      #  Ожидаемый формат:
=begin
      {
       <всяко-разные строчки>
      }

      <строка, начинающаяся НЕ с "-" или " " >

      {
       <строка-носитель    - начинается с " "> |
       <строка-разделитель - начинается с "-">
      }
=end

      # !!!! читаем С КОНЦА репорта
      begin
        s = smp_rep.pop
        next if s[0..0] == "-" # типа "строка-разделитель"

        if s[0..0] == " " then
          jump, jumpInfo = numbStrs2samplerJumpInfo(saplerLine2numbStrs(s))
          @samplerTable[jump] = jumpInfo
        else
          goodLine = false
        end
      end while goodLine

      @samplerTable
    end #def samplerReport2samplerTable(smp_rep)

end #class ModelTransform


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#***********************************************************************
public
# " Нагружение УГП данными Sampler-репорта "
# == Сборка ГНД программы из УГП и отчета Sampler-а
# Вход:  samplerModel - УГП (Graphs::SamplerGraph::Model)
#        samplerTable - отчет Sampler-а (Хеш-таблица ...)
# Выход:  - ГНД программы (Objects::AMC::Model)
def samplerGraph2arcGraph(samplerModel, samplerTable)
  samplerArc = Objects::AMC::Model.new("ArcModel")

  # вершины - тупо копируем
  samplerModel.nodes.each do |node|
    newNode = samplerArc.appendNode(node.name, Objects::AMC::Top)
    newNode.name = node.name
    newNode.nx = node.nx
    newNode.ny = node.ny
    newNode.w  = node.w
    newNode.h  = node.h
  end

  samplerModel.links.each do |link|
    arcLink = samplerArc.appendLink(
                  samplerArc.makeSource(samplerArc, link),
                  samplerArc.makeDest(samplerArc, link),
                  link.name
    )
    arcLink.nx = link.nx
    arcLink.ny = link.ny
    arcLink.w  = link.w
    arcLink.h  = link.h

    infoStr, topStr, downStr = link.info, link.up,  link.down

    #расчет вероятностей и нагрузок для ветвей
    if downStr.nil? then
    # Простая дуга, без ветвлений
      arcLink.probability = 1.0

      jmp = topStr.split(";")[0]

      time =    samplerTable[jmp].nil? ? 0.0 : samplerTable[jmp][:time]
      arcLink.intensity = (jmp == "0") ? 0.0 : time
    else # downStr.nil?
    # Дуга - часть ветвления
      topVal  =  topStr.split(";")
      downVal = downStr.split(";")

      # Вычленение из таблицы table значений <кол-во> и <время>
      # для перехода jmp (формата "t1-->t2" или "0")
      def getJmpInfo(table, jmp)
        info = table[jmp]
        n = info.nil? ? 0.0 : info[:count]
        t = info.nil? ? 0.0 : info[:time]

        return n, t
      end #def getJmpInfo(table, jmp)

      #Извлекаем из таблицы пары <кол-во> и <время>
      n1, t1 = getJmpInfo( samplerTable, topVal[0]  )
      n2, t2 = getJmpInfo( samplerTable, topVal[1]  )
      n3, t3 = getJmpInfo( samplerTable, downVal[0] )
      n4, t4 = getJmpInfo( samplerTable, downVal[1] )

      # считаем вероятности и нагрузку по общей формуле
      nUp  = n1 + n2
      nAll = nUp + n3 + n4
      tUp  = n1*t1 + n2*t2

      arcLink.probability = nAll.zero? ? 0.0 : nUp.to_f/nAll
      arcLink.intensity   = tUp.zero?  ? 0.0 : tUp.to_f/nUp
    end # if downStr.nil?
  end # samplerModel.links.each do |link|
  samplerArc
end

################################################################
##                                                            ##
##        Рассчет покрытия графа                              ##
##                                                            ##
##============================================================##
##  Вход:    ГНД, samplerGraph (Objects::AMC::Model)          ##
##  Выход:   общее количество дуг, количество ненагруженных   ##
##            дуг, массив имен ненагруженных дуг              ##
################################################################
def coverPartition(samplerGraph)
  nameArr = Array.new;
  sumLinkCnt = 0;
  emptyLinkCnt = 0;
  # проходим по всем дугам графа и смотрим на их параметры
  # у ненагруженных дуг вероятность (и нагрузка) равна(ы) нулю
    samplerGraph.links.each { |link|
      if (link.probability == 0)
        nameArr.push(link.name)
        emptyLinkCnt+=1
      end
      sumLinkCnt+=1;
  }
  return sumLinkCnt, emptyLinkCnt, nameArr
end