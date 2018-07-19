class GroupPolicy < ApplicationPolicy
  def index?
    if Figaro.env.enable_check_gate == 'true'
      gate_groups = GateWrapper.new(user).check_user_groups.symbolize_keys[:groups] || []
      return Group.all if Group.where(name: gate_groups).count > 0
    end

    user.admin? || GroupUser.where(user: user).count > 0
  end

  def show?
    index?
  end

  def new?
    index?
  end

  def create?
    index?
  end

  def destroy?
    index?
  end
end
