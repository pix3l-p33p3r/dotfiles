import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Item {
  property var user: userField.text
  property var password: passwordField.text
  property var session: sessionPanel.session
  property real inputHeight: Screen.height * 0.040
  property real inputWidth: Screen.width * 0.16
  Rectangle {
    id: loginBackground
    anchors {
      verticalCenter: parent.verticalCenter
      left: parent.left
      leftMargin: 10
    }
    height: inputHeight * 5.3
    width: inputWidth * 1.2
    radius: 5
    visible: config.LoginBackground == "true" ? true : false
    color: "#181825"
  }
  // Avatar in top-left (positioned below clock)
  Rectangle {
    id: avatarContainer
    visible: config.UserIcon == "true" ? true : false
    width: inputHeight * 5.7
    height: inputHeight * 5.7
    color: "transparent"
    anchors {
      top: parent.top
      left: parent.left
      topMargin: Screen.height * 0.14
      leftMargin: 10
    }
    z: 5
    Image {
      source: Qt.resolvedUrl("../assets/defaultIcon.png")
      height: parent.width
      width: parent.width
    }
    Image {
      // common icon path for KDE and GNOME
      source: Qt.resolvedUrl("/var/lib/AccountsService/icons/" + user)
      height: parent.width
      width: parent.width
    }
    Image {
      source: Qt.resolvedUrl(config.LoginBackground == "true" ? "../assets/maskDark.svg" : "../assets/mask.svg")
      height: parent.width
      width: parent.width
    }
    Image {
      source: Qt.resolvedUrl("../assets/ring.svg")
      height: parent.width
      width: parent.width
    }
  }

  // Login form in center-left
  Column {
    spacing: 8
    z: 5
    width: inputWidth
    anchors {
      verticalCenter: parent.verticalCenter
      left: parent.left
      leftMargin: 10
    }
    UserField {
      id: userField
      height: inputHeight
      width: parent.width
    }
    PasswordField {
      id: passwordField
      height: inputHeight
      width: parent.width
      onAccepted: loginButton.clicked()
    }
    Button {
      id: loginButton
      height: inputHeight
      width: parent.width
      enabled: user != "" && password != "" ? true : false
      hoverEnabled: true
      contentItem: Text {
        id: buttonText
        renderType: Text.NativeRendering
        font {
          family: config.Font
          pointSize: config.FontSize
          bold: true
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: "#11111B"
        text: "Login"
      }
      background: Rectangle {
        id: buttonBackground
        color: "#CBA6F7"
        radius: 3
      }
      states: [
        State {
          name: "pressed"
          when: loginButton.down
          PropertyChanges {
            target: buttonBackground
            color: "#b890f5"
          }
        },
        State {
          name: "hovered"
          when: loginButton.hovered && !loginButton.down
          PropertyChanges {
            target: buttonBackground
            color: "#d8bdfb"
          }
        }
      ]
      transitions: Transition {
        PropertyAnimation {
          properties: "color"
          duration: 300
        }
      }
      onClicked: {
        sddm.login(user, password, session)
      }
    }
  }

  // Session panel and Power buttons (Power, Reboot, Sleep) grouped in bottom-left
  Row {
    spacing: 8
    anchors {
      bottom: parent.bottom
      left: parent.left
      leftMargin: 10
    }
    z: 5
    SessionPanel {
      id: sessionPanel
    }
    PowerButton {
      id: powerButton
    }
    RebootButton {
      id: rebootButton
    }
    SleepButton {
      id: sleepButton
    }
  }
  Connections {
    target: sddm

    function onLoginFailed() {
      passwordField.text = ""
      passwordField.focus = true
    }
  }
}
