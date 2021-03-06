module Editstore
  class ObjectLock < Connection

    # THESE REALLY BELONG IN THE CONTROLLER and are only necessary for mass assignment
    # def objectlock_params
    #      params.require(:objectlock).permit(:locked, :druid)
    # end

    def self.prune_all
      self.where(:locked=>nil).destroy_all # anything that is not locked
    end

    def self.prune
      self.where(:locked=>nil).where('updated_at < ?',1.month.ago).each {|obj| obj.destroy}  # anything that is not locked older than 1 month
    end

    def self.unlock_all
      self.all_locked.each {|obj| obj.unlock} # unlock anything that is locked
    end

    def self.get_pid(pid)
      pid.start_with?('druid:') ? pid : "druid:#{pid}"
    end

    def self.all_locked
      self.where('locked IS NOT NULL')
    end

    def self.all_unlocked
      self.where(:locked=>nil)
    end

    # some convenience class level methods for operating on a specific druid
    def self.lock(pid)
      status=self.find_by_druid(self.get_pid(pid))
      if status # this druid already exists in the table
        return status.lock
      else # this druid does not exist in the table, create it and lock
         self.create(:druid=>self.get_pid(pid),:locked=>Time.now)
         return true
      end
    end

    def self.unlock(pid)
     status=self.find_by_druid(self.get_pid(pid))
     if status # this druid already exists in the table
         return status.unlock
      else
        return false # druid doesn't exist, can't unlock
      end
    end

    # check to see if this druid is locked
    def self.locked?(pid)
      status=self.find_by_druid(self.get_pid(pid))
      status.nil? ? false : status.locked?
    end

    # object level methods for performing actions
    def locked?
      !unlocked?
    end

    def unlocked?
      locked == nil
    end

    # lock this object
    def lock
       if unlocked?
         self.locked = Time.now
         save
         return true # lock at the current time
      else
        return false # already locked
      end
    end

    # unlock this object
    def unlock
      if locked?
         self.locked = nil
         save
         return true # unlock it
      else
        return false # already unlocked
      end
    end

 end
end
