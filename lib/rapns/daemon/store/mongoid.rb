require 'mongoid'

module Rapns
  module Daemon
    module Store
      class Mongoid

        DEFAULT_MARK_OPTIONS = {:persist => true}

        def deliverable_notifications(apps)
          batch_size = Rapns.config.batch_size
          relation = Rapns::Notification.ready_for_delivery.for_apps(apps)
          relation = relation.limit(batch_size) unless Rapns.config.push
          relation.to_a
        end

        def mark_retryable(notification, deliver_after, opts = {})
          opts = DEFAULT_MARK_OPTIONS.dup.merge(opts)
          notification.retries += 1
          notification.deliver_after = deliver_after

          if opts[:persist]
            notification.save!(:validate => false)
          end
        end

        def mark_batch_retryable(notifications, deliver_after)
          # mongoid does not support atomic updates of multiple fields for multiple objects
          notifications.each do |n|
            mark_retryable(n, deliver_after, :persist => true)
          end
        end

        # it looks like we don't need this anymore
        def retry_after(notification, deliver_after)
          notification.retries += 1
          notification.deliver_after = deliver_after
          notification.save!(:validate => false)
        end

        def mark_delivered(notification, time, opts = {})
          opts = DEFAULT_MARK_OPTIONS.dup.merge(opts)
          notification.delivered = true
          notification.delivered_at = time
          if opts[:persist]
            notification.save!(:validate => false)
          end
        end

        def mark_batch_delivered(notifications)
          now = Time.now
          # mongoid does not support atomic updates of multiple fields for multiple objects
          notifications.each do |n|
            mark_delivered(n, now, :persist => true)
          end
        end

        def mark_failed(notification, code, description, time, opts = {})
          opts = DEFAULT_MARK_OPTIONS.dup.merge(opts)
          notification.delivered = false
          notification.delivered_at = nil
          notification.failed = true
          notification.failed_at = time
          notification.error_code = code
          notification.error_description = description
          if opts[:persist]
            notification.save!(:validate => false)
          end
        end

        def mark_batch_failed(notifications, code, description)
          now = Time.now
          # mongoid does not support atomic updates of multiple fields for multiple objects
          notifications.each do |n|
            mark_failed(n, code, description, now, :persist => true)
          end
        end

        def create_apns_feedback(failed_at, device_token, app)
          Rapns::Apns::Feedback.create!(:failed_at => failed_at,
              :device_token => device_token, :app => app)
        end

        def create_gcm_notification(attrs, data, registration_ids, deliver_after, app)
          notification = Rapns::Gcm::Notification.new
          create_gcm_like_notification(notification, attrs, data, registration_ids, deliver_after, app)
        end

        def create_adm_notification(attrs, data, registration_ids, deliver_after, app)
          notification = Rapns::Adm::Notification.new
          create_gcm_like_notification(notification, attrs, data, registration_ids, deliver_after, app)
        end

        def update_app(app)
          app.save!
        end

        def update_notification(notification)
          notification.save!
        end

        def after_daemonize

        end

        private

        def create_gcm_like_notification(notification, attrs, data, registration_ids, deliver_after, app)
          notification.assign_attributes(attrs)
          notification.data = data
          notification.registration_ids = registration_ids
          notification.deliver_after = deliver_after
          notification.app = app
          notification.save!
          notification
        end

      end
    end
  end
end
