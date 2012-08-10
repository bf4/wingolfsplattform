# -*- coding: utf-8 -*-
module WorkflowKit
  class RemoveFromGroupBrick < Brick
    def name 
      "Aus Gruppe entfernen"
    end
    def description
      "Beendet die Mitgliedschaft des Benutzers, der dem Workflow als Parameter übergeben wird, " +
        "in der Gruppe, die dem Workflow als Parameter übergeben wird."
    end
    def execute( params )
      raise 'no user_id given' unless params[ :user_id ]
      raise 'no group_id given' unless params[ :group_id ]

      user = User.find( params[ :user_id ] ) 
      group = Group.find( params[ :group_id ] )

      UserGroupMembership.find_by( user: user, group: group ).destroy
    end
  end
end