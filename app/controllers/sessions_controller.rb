# -*- coding: utf-8 -*-
class SessionsController < ApplicationController

  # Die Session-Variablen @session und @current_user werden in app/controller/applicationcontroller.rb gefüllt
  # und sind dann für alle Controller verfügbar.

  def new
    @title = t :login
  end

  def create
    @title = t :login
    begin
      @current_user = User.authenticate( params[ :login_name ], params[ :password ] )
      if @current_user
        @session.login @current_user
        redirect_to :controller => "users", :action => "show", :alias => @current_user.alias
      else
        flash[ :error ] = t( :login_failed )
        render :action => "new"
      end
    rescue => exception
      flash[ :error ] = t exception
      render :action => "new"
    end
  end

  def logout
    @session.logout
    redirect_after_logout
  end

  def destroy
    @session.destroy
    redirect_after_logout
  end

  private

  def redirect_after_logout
    flash[ :notice ] = t :good_bye
    redirect_to :action => "new"
  end

end
