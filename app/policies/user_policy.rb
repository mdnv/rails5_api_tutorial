class UserPolicy < ApplicationPolicy
  def create?
    return Regular.new(record)
  end

  def show?
    return Guest.new(record) unless user
    return Admin.new(record) if user.admin?
    return Regular.new(record)
  end

  def update?
    raise Pundit::NotAuthorizedError unless user
    return Admin.new(record) if user.admin?
    return Regular.new(record)
  end

  def destroy?
    raise Pundit::NotAuthorizedError unless user
    return Admin.new(record) if user.admin?
    return Regular.new(record)
  end

  class Scope < Scope
    def resolve
      return Guest.new(record, User) unless user
      return Admin.new(scope, User) if user.admin?
      return Regular.new(scope, User)
    end
  end

  class Admin < FlexiblePermissions::Base
    class Fields < self::Fields
      def permitted
        super + [
          :links, :following_state, :follower_state
        ]
      end
    end

    class Includes < self::Includes
      def transformations
        {following: :followings}
      end
    end
  end

  class Regular < Admin
    class Fields < self::Fields
      def permitted
        super - [
          :activated, :activated_at, :activation_digest, :admin,
          :password_digest, :remember_digest, :reset_digest, :reset_sent_at,
          :token, :updated_at,
        ]
      end
    end
  end

  class Guest < Regular
    class Fields < self::Fields
      def permitted
        super - [:following_state, :follower_state]
      end
    end
  end
end