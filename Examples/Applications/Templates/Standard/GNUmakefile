include $(GNUSTEP_MAKEFILES)/common.make

#
# Replace 'MyApplication' with your application name
#
APP_NAME = MyApplication

MyApplication_HEADERS = MainController.h
MyApplication_OBJC_FILES = main.m MainController.m
MyApplication_RESOURCE_FILES = \
 MainMenu-GNUstep.gsmarkup \
 MainMenu-OSX.gsmarkup \
 MainWindow.gsmarkup

ifeq ($(FOUNDATION_LIB), apple)
  ADDITIONAL_GUI_LIBS += -framework Renaissance
else
  ADDITIONAL_GUI_LIBS += -lRenaissance
endif

include $(GNUSTEP_MAKEFILES)/application.make


