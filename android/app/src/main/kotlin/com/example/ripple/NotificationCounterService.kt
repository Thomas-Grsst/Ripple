package com.example.ripple

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

class NotificationCounterService : NotificationListenerService() {
    override fun onListenerConnected() {
        refresh()
    }

    override fun onListenerDisconnected() {
        counts = emptyMap()
        publishCurrent()
    }

    override fun onNotificationPosted(notification: StatusBarNotification) = refresh()

    override fun onNotificationRemoved(notification: StatusBarNotification) = refresh()

    private fun refresh() {
        counts = try {
            activeNotifications
                .filter { it.isClearable && !it.isOngoing }
                .groupingBy { it.packageName }
                .eachCount()
        } catch (exception: SecurityException) {
            emptyMap()
        }
        publishCurrent()
    }

    companion object {
        private var counts: Map<String, Int> = emptyMap()
        var listener: ((Map<String, Int>) -> Unit)? = null

        fun publishCurrent() {
            listener?.invoke(counts)
        }
    }
}
