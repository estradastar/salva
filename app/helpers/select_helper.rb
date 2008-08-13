require 'finder'
require 'application_helper'
require 'labels'
module SelectHelper
  include ApplicationHelper
  include Labels
  include ActionView::Helpers::FormOptionsHelper

  def selectize_id(object, field, selected=nil, filter={})
    selected_id = nil
    # Default value from filter has priority over defined state_id or selected option
    if filter.is_a? Hash and filter.has_key?(field) and !filter[field].nil?
      selected_id = filter[field]
    elsif !object.nil? and object.respond_to? field and !object.send(field).nil?
      selected_id = object.send(field)
    elsif !selected.nil?
      selected_id = selected.to_i
    end
    selected_id = selected_id.to_i if selected_id.is_a? String and !selected_id.strip.empty?
    selected_id.to_i if !selected_id.nil? and selected_id.to_i > 0
  end

  def finder_id(model, id, attributes=[])
    if id == :first || id == :last
      options = { }
    else
      options = { :conditions => "#{Inflector.tableize(model).pluralize}.id = #{id}" }
    end

    unless attributes.nil? or attributes.empty?
      if attributes.is_a? Array
        options[:attributes] = attributes
      else
        options[:column] = attributes
      end
    end
    Finder.new(model, :first, options).as_pair
  end

  def simple_select(object, model, tabindex, options={})
    field = options[:field] || foreignize(model,options[:prefix])
    selected = selectize_id((eval "@#{object}"), field, options[:selected], @filter)
    list = Finder.new(model, options).as_pair
    selected = list.first[0] if selected == :first
    selected = list.last[0] if selected == :last
    list += finder_id(model, selected, options[:attributes])  if !selected.nil? && list.rassoc(selected.to_i).nil?
    select(object, field, list, { :prompt => '-- Seleccionar --', :selected => selected}, {:tabindex => tabindex})
  end

  def select_conditions(object, model, tabindex, options={})
    field = options[:field] || foreignize(model,options[:prefix])
    selected = selectize_id((eval"@#{object}"), field, options[:selected], @filter)
    list = Finder.new(model, :all, options).as_pair
    list += finder_id(model, selected, options[:attributes])  if !selected.nil? && list.rassoc(selected.to_i).nil?
    select(object, field, list, { :prompt => '-- Seleccionar --', :selected => selected}, {:tabindex => tabindex})
  end

  def observable_select(partial, id, tabindex)
    render :partial => "salva/#{partial}", :locals => { :id => id, :tabindex => tabindex }
  end

  def simple_observable_select(partial, id, tabindex)
    model = Inflector.camelize(partial.split('_').last).constantize
    column = foreignize(partial.split('_')[1])
    render :partial => "salva/simple_observable_select", :locals => { :id => id, :tabindex => tabindex, :model => model, :column => column}
  end
end
