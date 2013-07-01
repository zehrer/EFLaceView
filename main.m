//
//  main.m
//  EFLaceViewCoreData
//
//  Created by MacBook Pro ef on 06/08/06.
//  Copyright Edouard FISCHER 2006 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[], char** envp)
{
	int res;
	setenv("XCODE_COLORS", "YES", &res);
  	char** env;
	for (env = envp; *env != 0; env++)
	{
		char* thisEnv = *env;
		printf("%s\n", thisEnv);    
	}
	return NSApplicationMain(argc, (const char **) argv);
}
